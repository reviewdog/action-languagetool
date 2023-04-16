import * as builder from "annotatedtext";
import fs from "fs";
import process from "process";
import mark from "remark-parse";
import { unified } from "unified";

/**
 * Read a file and return its content as a string.
 * @param {string} filename - The name of the file to read.
 * @returns {string} The content of the file.
 */
function readFileContent(filename) {
  return fs.readFileSync(filename, "utf-8");
}

/**
 * Process the given text using the unified processor with the specified plugin.
 * @param {string} text - The text to process.
 * @param {Object} processor - The unified processor instance.
 * @returns {Object} The processed text.
 */
function processText(text, processor) {
  return processor.processSync(text).contents;
}

// Read filename as argument
const filename = process.argv[2];

// Read file content
const text = readFileContent(filename);

// Initialize the unified processor with the remark-parse plugin
const processor = unified().use(mark, { commonmark: true });

// Process the text and build the annotated text
const annotatedText = builder.build(text, processor.parse);

// Convert the annotated text to a JSON string and print it
console.log(JSON.stringify(annotatedText));
