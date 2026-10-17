import { globSync, readFileSync } from "node:fs";
import { relative } from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const suppression = /(?:eslint|oxlint)-disable|@ts-(?:ignore|nocheck)|fallow-ignore/u;
const exclude = [
	"**/node_modules/**",
	"**/.git/**",
	"**/dist/**",
	"**/build/**",
	"**/coverage/**",
	"**/.output/**",
	"**/.tanstack/**",
	relative(process.cwd(), fileURLToPath(import.meta.url))
];

for (const file of globSync("**/*.{ts,tsx,mts,cts}", { exclude })) {
	for (const [index, line] of readFileSync(file, "utf-8").split("\n").entries()) {
		if (suppression.test(line)) {
			process.stderr.write(
				`${file}:${index + 1}: Fix the code or configure a justified scoped override instead of suppressing checks.\n`
			);
			process.exitCode = 1;
		}
	}
}
