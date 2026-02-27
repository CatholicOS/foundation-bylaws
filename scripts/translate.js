#!/usr/bin/env node
"use strict";

const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

// ── Load .env.local (if present) ─────────────────────────────────────────────

const envLocalPath = path.resolve(__dirname, "..", ".env.local");
if (fs.existsSync(envLocalPath)) {
  for (const line of fs.readFileSync(envLocalPath, "utf8").split("\n")) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const eq = trimmed.indexOf("=");
    if (eq === -1) continue;
    const key = trimmed.slice(0, eq).trim();
    const val = trimmed.slice(eq + 1).trim().replace(/^["']|["']$/g, "");
    if (!(key in process.env)) process.env[key] = val;
  }
}

// ── Argument parsing ──────────────────────────────────────────────────────────

const args = process.argv.slice(2);
const langs = [];

for (let i = 0; i < args.length; i++) {
  if (args[i] === "--lang" && args[i + 1]) {
    langs.push(args[++i]);
  }
}

if (langs.length === 0) {
  console.error("Usage: npm run translate -- --lang <code> [--lang <code> ...]");
  console.error("Examples:");
  console.error("  npm run translate -- --lang es");
  console.error("  npm run translate -- --lang es --lang fr --lang la");
  process.exit(1);
}

if (!process.env.OPENAI_API_KEY) {
  console.error("Error: OPENAI_API_KEY environment variable is not set.");
  process.exit(1);
}

// ── Paths ─────────────────────────────────────────────────────────────────────

const repoRoot = path.resolve(__dirname, "..");
const bylawsSrc = path.join(repoRoot, "BYLAWS.md");
const distDir = path.join(repoRoot, "dist");
const cssPath = path.join(repoRoot, "scripts", "bylaws-print.css");

if (!fs.existsSync(bylawsSrc)) {
  console.error(`Error: Source file not found: ${bylawsSrc}`);
  process.exit(1);
}

fs.mkdirSync(distDir, { recursive: true });

const bylawsText = fs.readFileSync(bylawsSrc, "utf8");

// ── OpenAI translation ────────────────────────────────────────────────────────

const SYSTEM_PROMPT = `You are a professional legal translator.
Translate the provided Markdown bylaws document into the requested language according to these rules:

1. Preserve all Markdown formatting exactly: headings (#, ##, ###), bold (**text**), italic (*text*), lists (-, *), horizontal rules (---), and all other Markdown syntax.
2. Preserve the metadata block verbatim — do not translate the field names or values for: Version:, Original Adoption Date:, Last Amended:.
3. Preserve the organization name "Catholic Digital Commons Foundation" verbatim in every occurrence.
4. Translate ecclesiastical titles naturally (e.g. "Holy See" → "Santa Sede", "Vatican" → "Vaticano").
5. Preserve legal citations verbatim: "Section 501(c)(3)", "Internal Revenue Code", "Texas Business Organizations Code".
6. Translate all other content faithfully and with legal precision.
7. Output ONLY the translated Markdown document — no preamble, no explanation, no code fences.`;

async function translateToLanguage(lang) {
  console.log(`\nTranslating to language: ${lang}`);

  const requestBody = {
    model: "gpt-4o",
    messages: [
      { role: "system", content: SYSTEM_PROMPT },
      {
        role: "user",
        content: `Translate the following Markdown bylaws document into the language with BCP 47 code "${lang}":\n\n${bylawsText}`,
      },
    ],
    temperature: 0.2,
  };

  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
    },
    body: JSON.stringify(requestBody),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    console.error(`Error: OpenAI API returned ${response.status} ${response.statusText}`);
    console.error(errorBody);
    process.exit(1);
  }

  const data = await response.json();
  const translatedText = data.choices[0].message.content;

  // ── Write translated Markdown ───────────────────────────────────────────────

  const mdOut = path.join(distDir, `bylaws-${lang}.md`);
  fs.writeFileSync(mdOut, translatedText, "utf8");
  console.log(`  Written: ${mdOut}`);

  // ── Pandoc: translated Markdown → standalone HTML ───────────────────────────

  const htmlOut = path.join(distDir, `bylaws-${lang}-standalone.html`);
  const pandocCmd = [
    "pandoc",
    mdOut,
    "--standalone",
    "--embed-resources",
    `--css ${cssPath}`,
    "-f markdown",
    "-t html5",
    `-o ${htmlOut}`,
  ].join(" ");

  console.log(`  Running pandoc...`);
  execSync(pandocCmd, { stdio: "inherit" });
  console.log(`  Written: ${htmlOut}`);

  // ── pagedjs-cli: standalone HTML → PDF ─────────────────────────────────────

  const pdfOut = path.join(distDir, `bylaws-${lang}.pdf`);
  const pagedjsCmd = [
    "npx pagedjs-cli",
    "--browserArgs='--no-sandbox'",
    htmlOut,
    `-o ${pdfOut}`,
  ].join(" ");

  console.log(`  Running pagedjs-cli...`);
  execSync(pagedjsCmd, { stdio: "inherit", cwd: repoRoot });
  console.log(`  Written: ${pdfOut}`);
}

// ── Main ──────────────────────────────────────────────────────────────────────

(async () => {
  for (const lang of langs) {
    await translateToLanguage(lang);
  }
  console.log("\nDone.");
})();
