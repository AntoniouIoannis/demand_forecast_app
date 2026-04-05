const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const db = admin.firestore();

// ---------------------------------------------------------------------------
// SMTP transport — configure via:
//   firebase functions:config:set smtp.host="smtp.gmail.com" smtp.port="465"
//   firebase functions:config:set smtp.user="youremail@gmail.com" smtp.pass="app-password"
// ---------------------------------------------------------------------------
function createTransport() {
  const cfg = (functions.config().smtp) || {};
  return nodemailer.createTransport({
    host: cfg.host || "smtp.gmail.com",
    port: parseInt(cfg.port || "465", 10),
    secure: true,
    auth: {
      user: cfg.user || "",
      pass: cfg.pass || "",
    },
  });
}

// ---------------------------------------------------------------------------
// NACE prefixes that indicate B2B (wholesale / services / professional)
// Everything else defaults to B2C
// ---------------------------------------------------------------------------
const B2B_NACE_PREFIXES = [
  "45", "46", "64", "65", "66", "69", "70", "71",
  "72", "73", "74", "77", "78", "79", "80", "81", "82",
];

function detectLeadType(userNaceCode) {
  if (!userNaceCode) return "B2C";
  const prefix = String(userNaceCode).split(".")[0];
  return B2B_NACE_PREFIXES.includes(prefix) ? "B2B" : "B2C";
}

// ---------------------------------------------------------------------------
// Email subject helpers
// ---------------------------------------------------------------------------
function buildSubject(leadType, companyName) {
  return leadType === "B2B"
    ? `🎯 Νέος Υποψήφιος B2B Πελάτης: ${companyName}`
    : `🛍️ Νέα Ευκαιρία Πώλησης: ${companyName}`;
}

// ---------------------------------------------------------------------------
// HTML email templates (Greek language)
// ---------------------------------------------------------------------------
function buildHtml(leadType, lead, userProfile) {
  const userName = `${userProfile.firstName || ""} ${userProfile.lastName || ""}`.trim() || "χρήστη";
  const city = lead.city || "-";
  const nace = lead.naceCode || "-";
  const legalForm = lead.legalForm || "-";
  const source = lead.source || "ΓΕΜΗ";
  const fitReason = lead.fitReason || "Ο ΚΑΔ της επιχείρησης εμπίπτει στο target NACE του προφίλ σας.";
  const score = lead.scoreValue ? `${(lead.scoreValue * 100).toFixed(0)}%` : "-";
  const websiteText = lead.website || "-";

  const headerBg = leadType === "B2B" ? "#1a73e8" : "#6a1b9a";
  const badgeBg = leadType === "B2B" ? "#e8f5e9" : "#f3e5f5";
  const badgeColor = leadType === "B2B" ? "#2e7d32" : "#6a1b9a";
  const fitBorder = leadType === "B2B" ? "#f9a825" : "#e91e63";
  const fitBg = leadType === "B2B" ? "#fffde7" : "#fce4ec";
  const ctaBg = headerBg;
  const typeLabel = leadType === "B2B"
    ? "B2B Ευκαιρία — νέος επαγγελματικός πελάτης"
    : "B2C Ευκαιρία — νέο κατάστημα / επιχείρηση στην περιοχή";
  const pitch = leadType === "B2B"
    ? "Επικοινωνήστε <strong>πριν</strong> προλάβει να συμφωνήσει με ανταγωνιστή σας."
    : "Χτυπήστε πρώτοι την πόρτα — πριν προλάβει Κωτσόβολος ή άλλη μεγάλη αλυσίδα.";

  return `<!DOCTYPE html>
<html lang="el">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<style>
  body{font-family:Arial,sans-serif;background:#f5f5f5;margin:0;padding:0}
  .wrap{max-width:600px;margin:20px auto;background:#fff;border-radius:8px;
        overflow:hidden;box-shadow:0 2px 12px rgba(0,0,0,.10)}
  .hdr{background:${headerBg};padding:24px 32px}
  .hdr h1{color:#fff;margin:0;font-size:20px}
  .hdr p{color:rgba(255,255,255,.75);margin:6px 0 0;font-size:13px}
  .body{padding:28px 32px}
  .badge{display:inline-block;background:${badgeBg};color:${badgeColor};
         padding:3px 12px;border-radius:20px;font-size:12px;font-weight:700;margin-bottom:14px}
  table.kv{width:100%;border-collapse:collapse;margin:16px 0}
  table.kv td{padding:8px 10px;border-bottom:1px solid #f0f0f0;font-size:14px}
  table.kv td:first-child{color:#555;width:38%}
  table.kv td:last-child{font-weight:600}
  .fit{background:${fitBg};border-left:4px solid ${fitBorder};
       padding:12px 16px;border-radius:0 6px 6px 0;margin:18px 0;font-size:14px}
  .cta{text-align:center;margin:24px 0 0}
  .cta a{background:${ctaBg};color:#fff;text-decoration:none;
         padding:12px 28px;border-radius:6px;font-weight:600;font-size:15px}
  .foot{background:#f5f5f5;padding:14px 32px;font-size:12px;color:#888}
</style>
</head>
<body>
<div class="wrap">
  <div class="hdr">
    <h1>📡 Sales Radar — Νέα Ευκαιρία!</h1>
    <p>${typeLabel}</p>
  </div>
  <div class="body">
    <div class="badge">HIGH PRIORITY &nbsp;·&nbsp; Score: ${score}</div>
    <p>Καλημέρα <strong>${userName}</strong>,</p>
    <p>Μόλις εντοπίστηκε νέα καταχώρηση στο <strong>${source}</strong> που ταιριάζει με το προφίλ σας.</p>
    <table class="kv">
      <tr><td>Επωνυμία</td><td>${lead.companyName || "-"}</td></tr>
      <tr><td>Νομική Μορφή</td><td>${legalForm}</td></tr>
      <tr><td>Έδρα</td><td>${city}</td></tr>
      <tr><td>Ιστότοπος</td><td>${websiteText}</td></tr>
      <tr><td>ΚΑΔ / NACE</td><td>${nace}</td></tr>
      <tr><td>Πηγή</td><td>${source}</td></tr>
    </table>
    <div class="fit">💡 <strong>Γιατί ταιριάζει:</strong> ${fitReason}</div>
    <p style="font-size:14px">${pitch}</p>
    <div class="cta">
      <a href="https://yourapp.page.link/radar">Άνοιγμα Radar →</a>
    </div>
  </div>
  <div class="foot">
    Λαμβάνετε αυτό το email ως συνδρομητής του Sales Radar.
    Πηγή δεδομένων: ${source}.
  </div>
</div>
</body>
</html>`;
}

// ---------------------------------------------------------------------------
// Cloud Function: onLeadCreated
// Fires whenever a new /leads document is written.
// Sends an HTML email only if scoreBand === "HIGH".
// ---------------------------------------------------------------------------
exports.onLeadCreated = functions.firestore
  .document("leads/{leadId}")
  .onCreate(async (snap, context) => {
    const lead = snap.data();

    // Only act on HIGH-priority leads
    if (!lead || lead.scoreBand !== "HIGH") return null;

    const ownerUid = lead.ownerUid;
    if (!ownerUid) return null;

    // --- Fetch owner email from Firebase Auth ---
    let userEmail;
    try {
      const userRecord = await admin.auth().getUser(ownerUid);
      userEmail = userRecord.email;
    } catch (err) {
      console.error("[Radar] Cannot fetch user record:", err);
      return null;
    }

    if (!userEmail) {
      console.warn("[Radar] User has no email:", ownerUid);
      return null;
    }

    // --- Fetch SME profile for personalisation ---
    const profileSnap = await db.collection("onhold_users").doc(ownerUid).get();
    const userProfile = profileSnap.exists ? profileSnap.data() : {};

    // --- Determine B2B / B2C from user's NACE code ---
    const leadType = detectLeadType(userProfile.naceCode || "");
    const subject = buildSubject(leadType, lead.companyName || "Νέα Επιχείρηση");
    const html = buildHtml(leadType, lead, userProfile);

    // --- Send email ---
    const transporter = createTransport();
    let deliveryStatus = "sent";
    let errorMessage = null;

    try {
      const smtpUser = (functions.config().smtp || {}).user || "noreply@salesradar.gr";
      await transporter.sendMail({
        from: `"Sales Radar" <${smtpUser}>`,
        to: userEmail,
        subject,
        html,
      });
      console.log(`[Radar] Email sent to ${userEmail} — lead ${context.params.leadId} (${leadType})`);
    } catch (err) {
      console.error("[Radar] Email send failed:", err);
      deliveryStatus = "failed";
      errorMessage = String(err);
    }

    // --- Record notification in Firestore (regardless of success/failure) ---
    await db.collection("notifications").add({
      ownerUid,
      leadId: context.params.leadId,
      companyName: lead.companyName || "",
      channel: "email",
      template: leadType,            // "B2B" | "B2C"
      deliveryStatus,
      errorMessage: errorMessage || null,
      sentAt: deliveryStatus === "sent"
        ? admin.firestore.FieldValue.serverTimestamp()
        : null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return null;
  });

