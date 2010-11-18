var toggle_checkboxes = function(state, class_name) {
	// Toggle all checkboxes with a given class either on or off
	$('DIV.items SPAN.checkbox_select INPUT.' + class_name).each(function(element, index) { state ? element.checked = true : element.checked = false; });
}

var onload_contests_index = function() {

	var default_caption = "Vote for the best caption or submit your own. Most votes wins!";

	// Change the default message if a user clicks on the text box
	if($('enter_caption')) {
		$('enter_caption').addEvent('click', function(event){
			if($('enter_caption').get("value") == default_caption) {
				$('enter_caption').set("value", "");
			}			
		});
	};
		
	// Prevent people from submitting with the default message or empty strings
	if($('new_caption')) {
		$('new_caption').addEvent('submit', function(event){
			if($('enter_caption').get("value") == default_caption || $('enter_caption').get("value").clean() == "") {
				return false;
			}
			
			// Prevent double clicks
			$('caption_submit').set("value", "wait");
			$('caption_submit').set("disabled", true);
		});
	};
		
	var vote_failure = function() {
		alert("Sorry. There was an error processing your vote. Please try again later");
	};
	
	// Add the vote functionality
	$$('INPUT.vote_submit').each(function(item, index) {

		// Get the auth token so we can do an ajax post
		try {
			var form = item.getParent();
			var action = form.get("action");
			var auth_token = form.getElement("INPUT[name=authenticity_token]").get("value");
			if(!form || !action || !auth_token) return false;
		} catch(e) {
			return false;
		}
		
		item.addEvent('click', function(event){ 
			
			// Hide all vote elements
			$$('INPUT.vote_submit').each(function(item) { item.addClass("hidden"); });
			
			// Show the message box 
			$('javascript_message').removeClass("hidden");
			$('javascript_message').set("html", "Thanks for voting! We're calculating the results. Be sure to check back later.");
			
			// Set the vote container html and show the user their favorite
			item.getParent('div.vote_container').getElement("div.user_voted").removeClass("hidden");
						
			var r = new Request.JSON({url: action, onFailure : vote_failure})
			r.post({"authenticity_token" : auth_token, "fc" : fc});
			return false;
		});
	});
};

var onload_users_categories = function() {
	var c = $('page_title').getElement(".check_all");
	var u = $('page_title').getElement(".uncheck_all");
	var cbs = $('categories').getElements("INPUT");
	add_check_all(c, u, cbs);
};

var onload_users_brands = function() {
	var c = $('page_title').getElement(".check_all");
	var u = $('page_title').getElement(".uncheck_all");
	var cbs = $('brands').getElements("INPUT");
	add_check_all(c, u, cbs);
};

var onload_users_departments = function() {
	var c = $('page_title').getElement(".check_all");
	var u = $('page_title').getElement(".uncheck_all");
	var cbs = $('departments').getElements("INPUT.departments");
	add_check_all(c, u, cbs);
};

var onload_users_signup = function() {

	// Categories
	var c = $('categories').getElement(".check_all");
	var u = $('categories').getElement(".uncheck_all");
	var cbs = $('categories').getElements("INPUT");
	add_check_all(c, u, cbs);

	var validate_signup_form = function() {
		if($$('.departments:checked').length == 0) {
			return js_error("Please select at least one department");
		}

		if($$('.categories:checked').length == 0) {
			return js_error("Please select at least one category");
		}
	}
		
	var eee = "Enter Your Email Address";
	if($('email_address').get("value") == eee) $('email_address').addClass("unselected");
		
	$('email_address').addEvent('click', function() {
		if($('email_address').get("value") != eee) return;
		$('email_address').set("value", "");
		$('email_address').removeClass("unselected");		
	});
	
	$('manual_submit').addEvent('click', function() {
		// Manually enter email
		var v = $('email_address').get("value");
		v = v.toLowerCase();
		if(!v.clean() || v == "enter your email address") {
			return js_error("Please enter an email address");
		}
				
		if(!$('recaptcha_response_field').get("value").clean()) {
			return js_error("Please enter a captcha value");			
		}
		
		return validate_signup_form();
	});
	
	$('fb_submit').addEvent('click', function() {
		// Handle the facebook connect scenario
		if(validate_signup_form() == false) return false;	
		FB.login(function(){ 
		
			FB.getLoginStatus(function(response) { 
				// If there is a connection redirect to /fb_login		
				if(response.status == "connected") $('signup_submit_form').submit();
			});	
			
		},{ perms: 'email' });
		return false;
	});	
};

var add_check_all = function(check_all, uncheck_all, check_boxes) {
	/* Adds check all functionality to a set of checkboxes. The method
		automatically assumes
	*/
	
	var check_em = function(trigger, check_boxes, state) {
		
		trigger.addEvent('click', function() {
			check_boxes.each(function(e2) { e2.set("checked", state); });
			return false;
		});
	};
	
	check_em(check_all, check_boxes, true);
	check_em(uncheck_all, check_boxes, false);	
};

var show_message = function(message, options) {
	
	if(options && options.spinner) $$('#js_msg IMG')[0].removeClass("hidden");
	
	$('m').set("html", message);
	$('js_msg').removeClass("hidden");
};

var hide_message = function() {
	$('js_msg').addClass("hidden");
	$$('#js_msg IMG')[0].addClass("hidden");
};

// Clean the crap out of input fields
var clean_text = function(s) {
	if(!s) return s;
	return s.stripTags().tidy().standardize(); 
}

var onload_friends_invite_friends = function() {
		
	// Create the modal for the friends select and add the content we will eventually show
	// http://www.jsfiddle.net/zNMQy/19/
	var modal = new Modal({
		"modal_id" : "contact_select_modal", 
		'content_id' : 'contact_select_content',
		'onButton': function(e, button) {
			e.stop();
		    this.hide();

			if(button == "ok") {
				// Update the friends_field and submit the form
				var checked = $$("#friends INPUT:checked");
				if(!checked || checked.length == 0) return false;

				//$('friends_container').addClass("hidden");
				show_message("Your contacts have been submitted. Please give us a few minutes to process them.");

				new Form.Request("friends_form", "").send();
		    }
		}
	});
	
	$('friends_container').inject('contact_select_content');
	
	$$('#services A').each(function(e) {
		e.addEvent('click', function() {
			var clicked = this;
			$$('#services A').each(function(e) { e.removeClass('selected'); });
			clicked.addClass('selected');
			return false;
		});
	});
		
	$('friends_form').addEvent('submit', function() { return false; });
	
	// Add multi-select behavior
	$('select_all').addEvent('click', function() {
		$$('#friends_data INPUT[TYPE=checkbox]').each(function(i) { i.checked = true; });
		return false;
	});

	$('unselect_all').addEvent('click', function() {
		$$('#friends_data INPUT[TYPE=checkbox]').each(function(i) { i.checked = false; });
		return false;		
	});

	$('get_contacts_form').addEvent('submit', function() { $('submit').click(); return false; });

	$('manual_invite_form').addEvent('submit', function() { 
		var t = $('manual_invite_text').get("value");
		t = t.clean();
		if(!t.length) return false;
	
		// Make sure this is legit text
		$('manual_message_textarea').set("value", clean_text( $('manual_message_textarea').get("value")) );
				
		new Form.Request("manual_invite_form", "").send();		
		show_message("Your contacts have been submitted. Please give us a few minutes to process them.");
		$('manual_invite_form').set("value", ""); // make sure this happens quickly
		$('manual_personal_container').dissolve(); // Close the box if it's open
		return false;
	});

	["auto", "manual"].each(function(e) {
		// Add Show/hide functionality to the personal message box		
		var link = $(e + "_message_show");
		link.addEvent('click', function() {
			var c = $(e + "_personal_container");
			c.style.display == "block" ? c.dissolve() : c.reveal();
			return false;			
		});	
	});
		
	$('submit').addEvent('click', function() {
		// User wants to get contacts...	
		
		// Set everything in the status back to default..
		hide_message();
		
		// Disable submit
		$('submit').disabled = true;
		
		// Error handling..		
		var selected = $$('#services A.selected');		
		if(selected.length == 0 || !selected[0].id) { $('submit').disabled = false; return false; }
		if(!$('username') || !$('password')) { $('submit').disabled = false; return false; }
		
		var service_name = selected[0].id;
		var un = $('username').get("value");
		var pwd = $('password').get("value");
		
		service_name = service_name.clean();
		un = un.clean();
		pwd = pwd.clean();		
		if(!un.length || !pwd.length || !service_name) { $('submit').disabled = false; return false; }

		show_message("Loading your contacts. Please wait...", {spinner : true});
		
		var data = {
			'username' : un, 
			'password' : pwd, 
			'service_name' : service_name, 
			'personal_message' : clean_text($('auto_message_textarea').get('value')) 
		};
		
		new Request.JSON({ method : "post", url: "/get_friends", data : data,
			onFailure : function() {
				alert("Sorry. There was a problem with your request. Please try again.")
			}, 
			onSuccess : function(r) {
				
				if(!r || r.result == "error") {
					show_message("There was a problem signing into your account.");
					return false;
				}
				
				// Delete existing table if it exists..
				if($("friends")) $("friends").destroy();
								
				if(r.contacts.length == 0) { return false; }

				var friends = create_contacts_table(r.contacts);				
				friends.inject('friends_data');
				modal.show();
			},
			onComplete : function() {
				$('auto_personal_container').dissolve();
				hide_message();
				$('submit').disabled = false; // let users submit again if they want
			}
		}).send();
		
		return false;		
	});

};

var onload_users_signup_complete = function() {

	// If there is a facebook user pop the invite friends shit
	FB.getLoginStatus(function(response) {
		
		if (!response.session) return;
	    
		FB.ui(
		  {
		    method: 'stream.publish',
			message: 'I just signed up for Gear Burger!',
		    attachment: {
				name: 'Share your love of gear!',
				description: (
				'Gear Burger tracks the products you want from the brands you like'
				+ ' and sends you an e-mail when they go on sale.'
		      ),
		      href: 'http://www.gearburger.com/'
		    },
		    action_links: [
				{ text: 'Check out Gear Burger', href: 'http://www.gearburger.com?cid=fbshare' }
		    ]
		  },
		  function(response) {
		    if (response && response.post_id) {
		      //alert('Post was published.');
		    } else {
		      //alert('Post was not published.');
		    }
		  }
		);
	});
	
};

var create_contacts_table = function(contacts) {
	
	var friends = new HtmlTable({
		properties : {
			id : "friends"
		},
		zebra : true
	});
	
	contacts.each(function(contact, index) {
				
		var select = new Element("td", { "class" : "select" });
		
		var checkbox = new Element("input", {
			"type" : "checkbox",
			"value" : contact[1],
			"name" : "friend[]",
			"checked" : true
		});

		checkbox.inject(select);		
					
		var name = new Element("td", { "html" : contact[0], "class" : "name" });
		var email = new Element("td", { "html" : contact[1], "class" : "email" });
		
		friends.push([checkbox, name, email]);
	});
	
	return friends;
};

var onload_users_new = function() {
	// Home Page
	
	// Periodic function that updates the product name on the home page
	var product_names = ["Arc'teryx", "Patagonia", "The North Face", "Mountain Hardwear",
		"Marmot", "Oakley", "Backcountry.com", "Black Diamond", "DAKINE", "Salomon",
		"Under Armour", "SmartWool", "Burton", "Outdoor Research", "Mammut", "K2",
		"CamelBak", "Cloudveil", "Columbia", "Adidas"];		

	var update_product_name = function() {		
		var rand = Math.floor(Math.random() * product_names.length);
		$('brand_name').set('html', product_names[rand]);
	};
	
	var id = update_product_name.periodical(2000);	
}

var onload_users_lost_password = function() {
	
	var lost_password_submit = function() {

		if(!$('email').value.clean()) {
			return js_error("Please enter an email address");
		}
		return true;
	};
	
	$('lost_password_form').addEvent('submit', lost_password_submit);
}

var onload_sessions_login = function() {
	$('login_form').addEvent('submit', login_form_submit);
}

var onload_users_show = function() {
	
	var send_newsletter_toggle = function() {

		$('send_newsletter_checkbox').disabled = true;

		function success(resultText) {
			$('send_newsletter_checkbox').checked = !$('send_newsletter_checkbox').checked;
		}

		function failure(xhr) {
			alert("error saving preference");
		};

		function complete() {
			$('send_newsletter_checkbox').disabled = false;		
			alert("Thanks!");
		}

		new Request.JSON({method : "get", url: "/toggle_newsletter", onFailure : failure, onSuccess : success, 
			onComplete : complete}).send();
		return false;
	};
	
	$('send_newsletter_checkbox').addEvent('click', send_newsletter_toggle);
}

var change_password_form_submit = function(event) {
	// Validate the change password form
	
	var pwd = $('password').value.clean();
	var confirm = $('confirm_password').value.clean()
	
	if(!pwd) {
		return js_error("Password cannot be empty");		
	}
	if(!confirm) {
		return js_error("Password confirm cannot be empty");
	}
	if(pwd != confirm) {
		return js_error("Passwords are not the same");		
	}
	
	if(pwd.length < 6) {
		return js_error("Password must be at least 6 characters");
	}
	return true;
};

var onload_users_change_password = function() {	
	$('change_password_form').addEvent('submit', change_password_form_submit);	
};

var onload_users_change_password_submit = function() {
	$('change_password_form').addEvent('submit', change_password_form_submit);		
};

var onload_login_form_submit = function(event) {

	// Don't submit a form without an email address
	if(!$('email_address').value.clean()) {
		return js_error("Please enter an email address");		
	}

	if(!$('password').value.clean()) {
		return js_error("Please enter a password");		
	}
	return true;
};

	
var get_product = function(data) {
	// Get a single product html object. The data is supplied by the
	// server and inserted as javascript into the template during render
	
	// Get the classes for the container. Add fresh if the product is from today
	/*
	var today = new Date();
	today.set("min", 0);
	today.set("hour", 0);
	today.set("sec", 0);
	var p_class = data.price_changed_at > today.valueOf() ? "product fresh" : "product";
	*/
	
	var product = new Element("div", { "class" : "product" });

	// Build image container
	var ic = new Element("div", { "class" : "image" });
	var href = new Element("a", { "href" : data.buy_url, "target" : "_blank" });
	var img = new Element("img", { "src" : data.small_image_url, "alt" : data.product_name });

	img.inject(href);
	href.inject(ic);

	// Build other containers
	var nc = new Element("div", { "class" : "name", "html" : data.product_name });
	var rc = new Element("div", { "class" : "retail", "html" : "Reg: $" + data.retail_price.toFixed(2) });
	var sc = new Element("div", { "class" : "sale", "html" : "$" + data.sale_price.toFixed(2) + " (" + (data.discount * 100.0).toPrecision(2) + "% OFF)" });

	ic.inject(product);
	nc.inject(product);
	rc.inject(product);
	sc.inject(product);
	return product;
};

var get_product_row = function(row_data) {
	var row = new Element("div", { "class" : "products_row" });
	row_data.each(function(e) {
		var p = get_product(e);
		p.inject(row);
	});

	var clear = new Element("div", { "class" : "clear" });
	clear.inject(row);

	return row;
};

var get_product_table = function(product_array, options) {

	var options = typeof(options) == "undefined" ? {} : options;
	var row_size = options["row_size"] ? options["row_size"] : 4;
	
	var container = new Element("div", { "id" : "products_table" });
	var row = [];

	// Slice data into rows
	for(var i=0; i < product_array.length; i += row_size) {
		var slice = product_array.slice(i, i + row_size);
		var p_row = get_product_row(slice);
		p_row.inject(container);
	}
	
	// Show / hide no_matches depending on result
	product_array.length == 0 ? $('no_matches').removeClass("hidden") : $('no_matches').addClass("hidden");
	
	// Optional insert into dom automatically
	if(options["update"]) {
		if($('products_table')) $('products_table').dispose()
		container.inject($(options["update"]));
	}
	
	return container;
};

var onload_users_gear_bin = function() {
																		
	var set_products = function() {
				
		// Set the products table after filtering by brand and category
		var p = [];

		// Get all of the ids of brands and cats and make sure they're integers
		var cats = $$('.category:checked').map(function(item) { return item.get("id").toInt() });
		var depts = $$('.department:checked').map(function(item) { return item.get("id").toInt() });
		depts.push(0); // 0 departments represent null departments which are always valid
		
		var min = $('min_price').get("value").toFloat();
		var max = $('max_price').get("value").toFloat();
		
		var discount = $('min_discount').getSelected()[0].get("value").toFloat();
		
		// Is the product date in the range?
		var freshness = $$('input[name=freshness]:checked')[0].get("value").toInt();
		
		for(var i=0; i < products.length; i++) {
			
			var product = products[i];
			
			// Is the price valid?
			if( product.sale_price < min || product.sale_price > max ) continue;			
						
			// Is the discount valid?
			if( product.discount.toPrecision(5).toFloat() < discount ) continue;
			
			// Is the product_changed_at less than the freshness level?
			if( product.price_changed_at < freshness ) continue;
																		
			// Is the product in category list
			if( !cats.contains(product.category_id) ) continue;
			
			// Is the product in the department list
			if ( !depts.contains(product.department_id) ) continue;
			
			// If everything passes push it into the result
			p.push(product);
		};		
				
		get_product_table(p, {"update" : "products_container" });
		
		// Set total matches
		$('matches_count').set("html", "(" + p.length + ")");
	};
		
	// Add events to all of the filters
	$$(".category").each(function(e) { e.addEvent('click', set_products); })
	$$(".department").each(function(e) { e.addEvent('click', set_products); })
	
	$('min_price').addEvent('keyup', set_products );
	$('max_price').addEvent('keyup', set_products );
	
	$('min_discount').addEvent('change', set_products);
	
	$$('input[name=freshness]').each(function(e) { e.addEvent('change', set_products); });

	// Render table the first time with default data		
	set_products();	
	
	$('see_more').addEvent("click", function() {
		
		page += 1;
		$('see_more').addClass("hidden");
		$('spinner').removeClass('hidden');
		
		var r = new Request.JSON({
			method : "get", 
			url: "/more_gear", 
			onSuccess : function(r) {
				if(r && r.products) {
					
					// If no more results then hide (see more)
					if(r.products.length != 0) $('see_more').removeClass("hidden");
					
					// Merge the product results together
					products.combine(r.products);
					set_products();
				}
			}, 
			onComplete : function() {
				$('spinner').addClass("hidden");
			}
		});
		
		r.get({"page" : page});
		return false;
	});
	
	// Add select all | none functionality to categories
	$$('.select_all').each(function(e) {
		e.addEvent("click", function() {
			var checked = this.get("html") == "all" ? true : false;
			$$('.category').each(function(i) { i.checked = checked });
			set_products();
		});
	});
};

