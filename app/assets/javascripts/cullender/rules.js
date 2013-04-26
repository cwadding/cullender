// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
// # check if there are any rules that have already been applied
// # if rules have been defined then check if the user is ok if we remove remove them from the form
// 
// jQuery ->
//   columns = $('#or_raise_field').html()	
//   table = $('#rule_table_id :selected').text()
//   escaped_table = table.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
//   options = $(columns).filter("optgroup[label=#{escaped_table}]").html()
//   $('#triggers').hide() unless options
//   $('#rule_table_id').change ->
//     table = $('#rule_table_id :selected').text()
//     escaped_table = table.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
//     options = $(columns).filter("optgroup[label=#{escaped_table}]").html()
//     if options
//       $('.column_select_field').html(options)
//       $('#triggers').show()      
//     else
//       $('.column_select_field').empty()
//       $('#triggers').hide()


// jQuery(function() {
// 	var columns;
// 	columns = $('#or_raise_field').html();
// 	populate_rule_column_options();
// 	$('#rule_table_id').change(populate_rule_column_options);

// 	function populate_rule_column_options(){
// 		var escaped_table, options, table;
// 		table = $('#rule_table_id :selected').text();
// 		escaped_table = table.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1');
// 		options = $(columns).filter("optgroup[label=" + escaped_table + "]").html();
// 		if (options) {
// 			$('.column_select_field').html(options);
// 			return $('#triggers').show();
// 		} else {
// 			$('.column_select_field').empty();
// 			return $('#triggers').hide();
// 		}
// 	}
// });

// TODO javascript without rails ujs