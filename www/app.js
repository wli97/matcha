App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("Entity.json", function(data) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.Entity = TruffleContract(data);
      // Connect provider to interact with contract
      App.contracts.Entity.setProvider(App.web3Provider);

      App.listenForEvents();
	
      return App.render();
    });
  },

  // Listen for events emitted from the contract
  listenForEvents: function() {
    App.contracts.Entity.deployed().then(function(instance) {
      // Restart Chrome if you are unable to receive this event
      // This is a known issue with Metamask
      // https://github.com/MetaMask/metamask-extension/issues/2393
      instance.claimRequest({}, {
        fromBlock: 0,
        toBlock: 'latest'
      }).watch(function(error, event) {
        console.log("event triggered", event);
        // Reload when a new vote is recorded
        App.render();
      });
    });
  },

  render: function() {
    // Load contract data
    App.contracts.Entity.deployed().then(function(instance) {
      entInstance = instance;
      return entInstance.getUser(App.account);
    }).then(function(me) {
      if (me[0] == 4){
	      var i = 0;
	      var requests = [];
	      do {
          var request = entInstance.getRequest(App.account,i);
		      i++;
		      if(request[0] === 0) i = -1;
		      else requests.push(request);
		    } while(i>=0);   
      }
      return resquests;
    }).then(function(data) {
      // Do not allow a user to vote
      if(hasVoted) {
        $('form').hide();
      }
      loader.hide();
      content.show();
    }).catch(function(error) {
      console.warn(error);
    });
    // Set loading state back to false
    App.loading = false;
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
