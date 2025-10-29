# Counsellor Dashboard - Student Mental Health Application

## Overview
The **Counsellor Dashboard** is a web-based interface designed for mental health counsellors to manage student wellness activities efficiently. It is part of the [Student Mental Health Application](#) and provides functionalities for appointments, anonymous Q&A, resource management, journals monitoring, and generating insights through reports.

The frontend is built using **React**, **TypeScript**, **Vite**, and **Tailwind CSS**. The design is professional, clean, and minimalistic, with a consistent color scheme aligned with the student-facing application.

## Features
- **Counsellor Login:** Secure login page with email and password authentication.
- **Dashboard Overview:** Quick view of upcoming appointments, pending requests, recent flagged journals, and new Q&A.
- **Appointments Management:** Approve, reschedule, or reject student requests. Includes calendar view toggle.
- **Anonymous Q&A:** Respond to anonymous student questions and mark them as answered.
- **Resources Management:** Upload, edit, and delete mental health resources with category organization.
- **Reports & Insights:** Export reports on appointments, journaling trends, and mood check-ins with visual graphs.
- **Responsive Design:** Optimized for desktop and tablet use.

## Color Palette
- **Primary Teal Green (#3CB371):** Main buttons and highlights.
- **Professional Secondary Deep Blue (#3A4A65):** Headers, navigation bar, key accents.
- **Neutral Grey-White (#F5F7FA):** Backgrounds.
- **Dark Charcoal (#333333):** Primary text.
- **Medium Grey (#666666):** Secondary text, hints, labels.
- **Peach (#FFB6A6):** Export buttons and highlights for visual emphasis.

## Project Structure
counsellor-dashboard/
├── public/ # Static assets (favicon, images, robots.txt)
├── src/
│ ├── components/ # UI and layout components
│ ├── hooks/ # Custom React hooks
│ ├── lib/ # Utility functions
│ ├── pages/ # Dashboard pages (Appointments, Q&A, Reports, etc.)
│ ├── App.tsx
│ ├── main.tsx
│ └── index.css
├── package.json
├── tailwind.config.ts
├── vite.config.ts
└── README.md

bash
Copy code

## Installation & Setup

1. Clone the repository:  
   ```bash
   git clone <repository-url>
   cd counsellor-dashboard
Install dependencies:

bash
Copy code
npm install
Start the development server:

bash
Copy code
npm run dev
Open the dashboard in your browser:
http://localhost:8080

Notes
Ensure you have Node.js v20.x installed for compatibility with Vite and SWC.

UI components are modular and reusable.

Some dev dependencies may show moderate vulnerabilities in npm audit; these are primarily development tools and safe for local development.

License
This project is licensed under the MIT License.