var common_functions = function() {
	
	if($('date_selector')) {
		$('date_selector').addEvent('change', function(e) {
			var id = $('date_selector').getSelected()[0].get("value");
						
			if(id == "last7") {
				var diff = 7;
			} else if(id == "last30") {
				var diff = 30;
			} else {
				var diff = 0;
			}
			
			var start_date = new Date().decrement("day", diff);
			
			$('start_date').set("value", start_date.format('%Y-%m-%d'));
			$('end_date').set("value", new Date().format('%Y-%m-%d'));
			
		});
	};	
};

var onload_brands_edit = function() {

	$$('.edit_brand')[0].addEvent("submit", function() {
		return confirm("Mapping permanently moves products and users from this brand. Are you sure?");
	});
};
 
var onload_contests_index = function() {
	swfobject.registerObject("flashCookie", "9.0.0");
	
	$('get_flash_cookie').addEvent("click", function(e) {
		$('flash_cookie').set("text", swfobject.getObjectById("flashCookie").getCookieValue());
	});

	$('set_flash_cookie').addEvent("click", function(e) {
		var c = $('logged_in_cookie').get("text");
		swfobject.getObjectById("flashCookie").setCookieValue(c);
		alert("flash cookie set to: " + c);
	});	
}

var onload_stats_summary = function() {

	var dates = {'start_date': $('start_date').value, 'end_date': $('end_date').value};

	// Get avantlink stats and then get google stats
	new Request.JSON({url: "/admin/avantlink_stats", 
		onSuccess: function(r) {
		  	$('revenue').set("html", r.revenue);
			$('clicks').set("html", r.clicks);
			$('sales').set("html", r.sales)
		} 
	}).get(dates);
			
	// Get avantlink stats and then get google stats
	new Request.JSON({url: "/admin/google_stats", 
		onSuccess: function(r) {
			
			// General site info..
		  	$('pageviews').set("html", r.pageviews);
			$('visits').set("html", r.visits);
			
			// Get the information about the sale_spot page 
			$('product_links_clicks').set("html", r.ss_clicks);
			$('product_links_views').set("html", r.ss_views);
			$('product_links_revenue').set("html", r.ss_revenue);
			$('product_links_click_rate').set("html", r.ss_rate);
			$('product_links_rpc').set("html", r.ss_rpc);
		},
	    onComplete: function(r) {
			$('indicator_loader').addClass("hidden");
		} 
	}).get(dates);	
};

var onload_stats_user_behavior = function() {
	new SortingTable('sort_table');	
};

var onload_feeds_index = function() {

	new SortingTable('sort_table');

	// Validation
	$("pull_feeds_submit").addEvent("click", function() {
		var cbs = $('feeds_form').getElements("INPUT");

		var checked = false;
		cbs.each(function(e) { if(e.checked) checked = true; });
		
		if(!checked) {
			alert("select some check boxes fool!");
			return false;
		}
	});
	
	var f = new Form.Request("feeds_form", "form_result");
		
	f.addEvent("send", function(form, data) {
		$('form_result').removeClass("hidden");		
		$('form_result').set("html", "Processing feeds... This may take a while");				
	});
};

var onload_feed_categories_index = function() {

	$('select_all').addEvent('click', function(e) {		
		$$('.check').each(function(e, i) { e.set("checked", true); });
		return false;
	});
	
	$('unselect_all').addEvent('click', function(e) {
		$$('.check').each(function(e, i) { e.set("checked", false); });
		return false;
	});
	
	$('clear').addEvent('click', function(e) {
				
		// Clear these fields
		["feed_category", "feed_subcategory", "feed_product_group"].each(function(i) { 
			$(i).set("value", "");
		});
		
		$('limit').set("value", 100);
		
		$('show_inactive').set("checked", false);
		
		// TODO: hard coded for now. Not really worth the time at this moment to get right 
		$('category_id').options[1].set("selected", true);
						
		return false;
	});
}