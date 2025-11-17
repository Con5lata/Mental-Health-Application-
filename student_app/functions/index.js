const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

/**
 * Sentiment analysis on write to journals/{entryId}
 */
exports.analyzeSentiment = onDocumentWritten("journals/{entryId}", async (event) => {
  const before = event.data.before;
  const after = event.data.after;

  // If deleted → exit
  if (!after) return;

  const journal = after.data();
  const entryId = event.params.entryId;

  // Skip if triggered only for backfilling
  if (journal?._backfill_trigger) {
    logger.log(`Backfill trigger detected for ${entryId}, ignoring content.`);
    return;
  }

  // Skip if no journal text
  if (!journal || !journal.entry || journal.entry.trim() === "") {
    logger.log(`Journal ${entryId} has no text to analyze. Exiting.`);
    return;
  }

  const text = journal.entry;

  // Avoid re-running on unchanged text
  const beforeData = before ? before.data() : {};
  const sentimentExists = journal.sentiment?.normalized !== undefined;

  if (before && beforeData.entry === text && sentimentExists) {
    logger.log(`Skipping analysis for ${entryId}: text unchanged.`);
    return;
  }

  // HuggingFace Inference settings
  const HF_API_KEY = process.env.HUGGINGFACE_KEY;
  const MODEL = "cardiffnlp/twitter-roberta-base-sentiment-latest";

  // Correct working HuggingFace Inference endpoint
  const MODEL_URL = `https://router.huggingface.co/hf-inference/models/${MODEL}`;

  try {
    const response = await axios.post(
      MODEL_URL,
      { inputs: text },
      {
        headers: {
          Authorization: `Bearer ${HF_API_KEY}`,
          "Content-Type": "application/json",
        },
      }
    );

    const results = response.data[0];
    const result = Array.isArray(results) ? results[0] : results;

    let normalized = 0;
    const label = result.label.toLowerCase();

    if (label === "positive") normalized = result.score;
    if (label === "negative") normalized = -result.score;

    await admin.firestore().collection("journals").doc(entryId).set(
      {
        sentiment: {
          label: result.label,
          score: result.score,
          normalized,
          analyzed_at: admin.firestore.FieldValue.serverTimestamp(),
          analysis_status: "complete",
        },
      },
      { merge: true }
    );

    logger.log(`Sentiment saved for journal ${entryId}`);
  } catch (error) {
    const msg = error.response ? error.response.data : error.message;
    logger.error(`Error analyzing sentiment for ${entryId}`, msg);

    await admin.firestore().collection("journals").doc(entryId).set(
      {
        sentiment: {
          error: msg,
          analyzed_at: admin.firestore.FieldValue.serverTimestamp(),
          analysis_status: "error",
        },
      },
      { merge: true }
    );
  }
});

/**
 * Callable function to backfill missing sentiment analysis
 */
exports.backfillSentimentData = onCall(async (request) => {
  logger.log("Starting sentiment backfill...");

  const db = admin.firestore();
  const journalsRef = db.collection("journals");

  let processedCount = 0;

  try {
    const snapshot = await journalsRef
      .where("sentiment.analysis_status", "not-in", ["complete", "error"])
      .limit(10) // Safe batch size for Cloud Functions time limits
      .get();

    if (snapshot.empty) {
      logger.log("No journals need backfilling.");
      return {
        success: true,
        message: "No entries needed backfilling.",
        processedCount: 0,
      };
    }

    const batchUpdates = [];

    snapshot.forEach((doc) => {
      batchUpdates.push(
        doc.ref.set(
          {
            _backfill_trigger: true,
          },
          { merge: true }
        )
      );
      processedCount++;
    });

    await Promise.all(batchUpdates);

    const message = `Queued ${processedCount} entries for sentiment analysis.`;

    logger.log(message);

    return { success: true, message, processedCount };
  } catch (error) {
    throw new HttpsError(
      "internal",
      "Error during backfill",
      error.message
    );
  }
});
