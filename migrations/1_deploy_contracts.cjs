const BatchTracking = artifacts.require("BatchTracking");

module.exports = async function(deployer) {
  console.log("Deploying BatchTracking contract...");
  await deployer.deploy(BatchTracking);
  const instance = await BatchTracking.deployed();
  console.log("✅ BatchTracking deployed at:", instance.address);
  console.log("\n📝 IMPORTANT: Copy this address to use in your apps!");
  console.log("Contract Address:", instance.address);
};
