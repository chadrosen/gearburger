/* These functions are called on every page */
var common_functions = function() {
	
	// Login button overlay...
	if($('login_button')) {
		
		// Create the modal for the friends select and add the content we will eventually show
		// http://www.jsfiddle.net/zNMQy/19/
		modal = new Modal({
			"modal_id" : "login_modal", 
			'content_id' : 'login_modal_content',
			'onButton': function(e, button) {
				e.stop();
			    this.hide();
			}
		});
		
		// Inject login modal code into the modal
		$('login_modal_form').inject("login_modal_content");
		$('login_modal_form').removeClass("hidden");
		
		$('create_account_link').addEvent('click', function(e) {
			e.stop();
			document.location = "/signup";
			return false;
		});
		
		$('login_button').addEvent('click', function(e) {
			e.stop();
			modal.show();
			return false;
		});		
	};
	
	if($('logout_button')) {
		$('logout_button').addEvent('click', function(e) {
			// If there is a facebook session log them out
			FB.logout(function(response) { window.location = "/logout"; });
		});
		return false;
	};	
};

var after_fb_login = function(goto_url) {
	// This function is called by the facebook connect login button
	// After the user attempts to connect
	FB.getLoginStatus(function(response) { 
		// If there is a connection redirect to /fb_login		
		if(response.status == "connected") window.location = goto_url;
	});	
};

var js_error = function(error) {
	$('js_error').removeClass('hidden');
	$('js_error').set("html", error);
	return false;
};