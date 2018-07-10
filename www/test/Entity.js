var Entity = artifacts.require("Entity");

contract("Entity", function(accounts) {
  var entInstance;

  it("Call owner", function() {
    return Entity.deployed().then(function(instance) {
      entInstance = instance;
      return instance.owner();
    }).then(function(address) {
      assert.equal(address, "0x7dc3600fe2823a113c5c5439e128ba6d3ea15a41", "They are equal");
    });
  });


})
