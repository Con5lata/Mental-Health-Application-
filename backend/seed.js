// backend/seed.js

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function seed() {
  try {
    // --- Users ---
    const students = [
      { name: "Alice Student", email: "alice@student.com", phone: "+254700111222" },
      { name: "Brian Student", email: "brian@student.com", phone: "+254700111333" },
      { name: "Clara Student", email: "clara@student.com", phone: "+254700111444" },
      { name: "David Student", email: "david@student.com", phone: "+254700111555" },
      { name: "Eva Student", email: "eva@student.com", phone: "+254700111666" },
    ];

    const counsellors = [
      { name: "Dr. Bob Counsellor", email: "bob@counsellor.com", phone: "+254700333444" },
      { name: "Dr. Mary Counsellor", email: "mary@counsellor.com", phone: "+254700333555" },
    ];

    const studentRefs = [];
    for (const s of students) {
      const ref = db.collection("users").doc();
      await ref.set({
        user_id: ref.id,
        ...s,
        role: "student",
        password_hash: "hashedpassword123",
        created_at: new Date(),
      });
      studentRefs.push(ref);
    }

    const counsellorRefs = [];
    for (const c of counsellors) {
      const ref = db.collection("users").doc();
      await ref.set({
        user_id: ref.id,
        ...c,
        role: "counsellor",
        password_hash: "hashedpassword456",
        created_at: new Date(),
      });
      counsellorRefs.push(ref);
    }

    // --- Journals & Moods ---
    for (const student of studentRefs) {
      await db.collection("journals").add({
        user_id: student.id,
        content: `Journal entry for ${student.id}`,
        tags: ["stress", "study"],
        created_at: new Date(),
      });

      await db.collection("moods").add({
        user_id: student.id,
        date: new Date(),
        score: Math.floor(Math.random() * 5) + 1,
        note: "Feeling mixed emotions today.",
      });
    }

    // --- Appointments ---
    const statuses = ["pending", "approved", "rescheduled", "cancelled"];
    for (let i = 0; i < 6; i++) {
      await db.collection("appointments").add({
        student_id: studentRefs[i % studentRefs.length].id,
        counsellor_id: counsellorRefs[i % counsellorRefs.length].id,
        slot: new Date(Date.now() + i * 86400000), // different days
        reason: `Session ${i + 1}`,
        status: statuses[i % statuses.length],
        notes: "",
      });
    }

    // --- Resources ---
    for (const counsellor of counsellorRefs) {
      await db.collection("resources").add({
        created_by: counsellor.id,
        title: `Wellness Guide by ${counsellor.id}`,
        body: "Tips for maintaining balance.",
        category: "Wellness",
        created_at: new Date(),
        views: Math.floor(Math.random() * 100),
      });
    }

    // --- Reports ---
    await db.collection("reports").add({
      owner_id: counsellorRefs[0].id,
      type: "Monthly Summary",
      date_range: "September 2025",
      file_ref: "report-sept-2025.pdf",
      created_at: new Date(),
    });

    // --- QnA + Answers ---
    const qnaRef = db.collection("qna").doc();
    await qnaRef.set({
      qna_id: qnaRef.id,
      author_id: studentRefs[0].id,
      question: "How can I manage exam anxiety?",
      created_at: new Date(),
      status: "open",
    });

    await db.collection("answers").add({
      qna_id: qnaRef.id,
      counsellor_id: counsellorRefs[0].id,
      answer_text: "Practice breathing techniques and maintain a study schedule.",
      created_at: new Date(),
    });

    console.log("✅ Firestore has been seeded with multiple records!");
  } catch (error) {
    console.error("❌ Error seeding Firestore:", error);
  }
}

seed();
