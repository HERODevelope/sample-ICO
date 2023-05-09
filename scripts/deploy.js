async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const ICOToken = await ethers.getContractFactory("ICOToken");
  token = await ICOToken.deploy();
  await token.deployed();

  const ICO = await ethers.getContractFactory("ICO");
  ico = await ICO.deploy(token.address);
  await ico.deployed();

  await token.transfer(ico.address, 5000);

  console.log("Token address:", token.address);
  console.log("ICO address:", ico.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
