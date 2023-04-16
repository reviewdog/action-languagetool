import * as builder from "annotatedtext";
import fs from "fs";
import process from "process";
import remarkGfm from "remark-gfm";
import remarkParse from "remark-parse";
import { unified } from "unified";

function readFileContent(filename) {
  return fs.readFileSync(filename, "utf-8");
}

function processText(text, processor) {
  return processor.processSync(text).contents;
}

const filename = process.argv[2];
const text = readFileContent(filename);
const processor = unified().use(remarkParse).use(remarkGfm);

const annotatedText = builder.build(text, processor.parse);
console.log(JSON.stringify(annotatedText));
