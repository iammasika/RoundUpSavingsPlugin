import fs from "fs";
import path from "path";

const OUT_DIR = "out";
const ABI_DIR = "abi";

if (fs.existsSync(ABI_DIR)) {
  fs.rmSync(ABI_DIR, { recursive: true, force: true }); // Deletes old files
}
fs.mkdirSync(ABI_DIR, { recursive: true });

// Read all contract JSON files in the `out/` directory
const extractAbi = () => {
  console.log("🔍 Extracting ABI files...");
  const files = fs.readdirSync(OUT_DIR);
  //   console.log(files);
  files.forEach((contract) => {
    const contractPath = path.join(OUT_DIR, contract);
    if (fs.lstatSync(contractPath).isDirectory()) {
      contract = contract.replace(".sol", "");
      const jsonFile = path.join(contractPath, contract + ".json");
      if (fs.existsSync(jsonFile)) {
        const contractData = JSON.parse(fs.readFileSync(jsonFile, "utf8"));
        if (contractData.abi) {
          const abiPath = path.join(ABI_DIR, contract + "Abi.ts");
          const formattedAbi = `export const ${contract}Abi = ${JSON.stringify(contractData.abi, null, 2)} as const;\n`;
          fs.writeFileSync(abiPath, formattedAbi);
          console.log(`✅ Extracted ABI: ${abiPath}`);
        }
      }
    }
  });
};

extractAbi();
