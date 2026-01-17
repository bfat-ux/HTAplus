const express = require("express");
const bodyParser = require("body-parser");
const nodemailer = require("nodemailer");
const cors = require("cors");
const rateLimit = require("express-rate-limit");
const helmet = require("helmet");
require("dotenv").config();

const app = express();
app.use(helmet());
app.use(bodyParser.json({ limit: "200kb" }));

const allowedOrigins = process.env.CORS_ORIGIN
  ? process.env.CORS_ORIGIN.split(",").map((origin) => origin.trim())
  : ["http://localhost:3000", "http://localhost:5173", "http://localhost:8080"];

app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (like mobile apps, Postman, or same-origin requests)
      if (!origin) {
        return callback(null, true);
      }
      // Allow if origin is in allowed list or if wildcard is set
      if (allowedOrigins.includes(origin) || allowedOrigins.includes("*")) {
        return callback(null, true);
      }
      // For development, allow localhost origins
      if (process.env.NODE_ENV !== "production" && origin.includes("localhost")) {
        return callback(null, true);
      }
      console.log(`CORS blocked origin: ${origin}`);
      return callback(new Error("Not allowed by CORS"));
    },
    credentials: true,
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
});

app.use("/api/", limiter);

// Contact handler function (reusable for both routes)
const handleContact = (req, res) => {
  const { name, email, message, interest } = req.body;

  if (!name || !email || !message) {
    return res.status(400).json({ error: "Name, email, and message are required." });
  }

  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: { user: process.env.EMAIL, pass: process.env.PASS },
  });

  // Format email body to include all information
  const emailBody = interest
    ? `Interested in: ${interest.charAt(0).toUpperCase() + interest.slice(1)}\n\nMessage:\n${message}`
    : `Message:\n${message}`;

  return transporter
    .sendMail({
      from: email,
      to: "bernardfatoye@gmail.com",
      subject: `HTA+ Inquiry from ${name}`,
      text: emailBody,
    })
    .then(() => res.json({ success: true }))
    .catch((err) => res.status(500).json({ error: err.message }));
};

// Handle both /api/contact and /contact (in case nginx strips /api/)
app.post("/api/contact", handleContact);
app.post("/contact", handleContact);

app.use((err, req, res, next) => {
  if (err.message === "Not allowed by CORS") {
    return res.status(403).json({ error: "CORS blocked" });
  }
  return next(err);
});

app.listen(3000, () => console.log("Server running on port 3000"));
