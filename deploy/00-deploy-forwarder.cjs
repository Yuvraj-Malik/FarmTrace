module.exports = async function (hre) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying MinimalForwarder...");
  
  const forwarder = await deploy('MinimalForwarder', {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: 1,
  });

  console.log("MinimalForwarder deployed to:", forwarder.address);
};

module.exports.tags = ['MinimalForwarder'];