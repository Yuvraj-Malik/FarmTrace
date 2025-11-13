module.exports = async function (hre) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();

  // Get the forwarder address from previous deployment
  const forwarder = await get('MinimalForwarder');
  
  console.log("Deploying CattleTrace with forwarder:", forwarder.address);
  
  const cattle = await deploy('CattleTrace', {
    from: deployer,
    args: [forwarder.address],
    log: true,
    waitConfirmations: 1,
  });

  console.log("CattleTrace deployed to:", cattle.address);
};

module.exports.tags = ['CattleTrace'];
module.exports.dependencies = ['MinimalForwarder'];