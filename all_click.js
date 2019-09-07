// publications images
	jQuery(document).on('click','.img-active',function(){
		id = jQuery(this).data('id');
		pic = jQuery(this).data('img');
		path = jQuery(this).data('path');
		uid = jQuery(this).data('uid');
		jQuery.post('/admin/_admin_ajax/__publicadmin.paj',{action:'active_pic',id:id,uid:uid,path:path,pic:pic},function(data){}).done(jQuery.post('/admin/_admin_ajax/__publicadmin.paj',{id:id,uid:uid,action:'edit_pub'},function(data){jQuery('#middle-panel').html(data)}))

		console.log(id + ',' + uid);
	});
	jQuery(document).on('click','.img-rotate',function(){
		id = jQuery(this).data('id');
		pic = jQuery(this).data('img');
		path = jQuery(this).data('path');
		uid = jQuery(this).data('uid');
		console.log(id + ',' + uid);
	});
	jQuery(document).on('click','.img-text',function(){
		id = jQuery(this).data('id');
		pic = jQuery(this).data('img');
		path = jQuery(this).data('path');
		uid = jQuery(this).data('uid');
		prompttext = jQuery(this).data('prompttext');
		console.log(id + ',' + uid);
		var txt = prompt(prompttext, '');
		jQuery.post('/admin/_admin_ajax/__publicadmin.paj',{action:'text_pic',id:id,uid:uid,path:path,pic:pic,txt:txt}).done(jQuery.post('/admin/_admin_ajax/__publicadmin.paj',{id:id,uid:uid,action:'edit_pub'},function(data){jQuery('#middle-panel').html(data)}))
	});
	jQuery(document).on('click','.img-delete',function(){
		id = jQuery(this).data('id');
		pic = jQuery(this).data('img');
		path = jQuery(this).data('path');
		uid = jQuery(this).data('uid');
		console.log(id + ',' + uid);
		jQuery.post('/admin/_admin_ajax/__publicadmin.paj',{action:'remove_pic',id:id,uid:uid,path:path,pic:pic}).done(jQuery.post('/admin/_admin_ajax/__publicadmin.paj',{id:id,uid:uid,action:'edit_pub'},function(data){jQuery('#middle-panel').html(data)}))
	});

// pub list actions

	jQuery(document).on('click','.list-remove',function(){
		section = jQuery('#section').val();
		uid = jQuery(this).data('uid');
		id = jQuery(this).data('id');
		confirmtext = jQuery(this).data('confirmtext');
		if (confirm(confirmtext)) {
			jQuery.post('_admin_ajax/__publicadmin.paj', {id : id, uid : uid, action : 'remove'})
			.done(
				jQuery('div#' + id).remove()
			)
//			.done(
//				jQuery.post('_admin_ajax/__publicadmin.paj', {action : 'list', uid : uid}, function(data){jQuery('#left-content').html(data);})
//			)
			.done(
				jQuery.post('_admin_ajax/__publicadmin.paj', {action : 'new_pub'}, function(data){jQuery('#middle-panel').html(data);})
			)
		}
	});
	jQuery(document).on('click','.list-edit',function(){
		section = jQuery('#section').val();
		uid = jQuery(this).data('uid');
		id = jQuery(this).data('id');
		jQuery.post('_admin_ajax/__publicadmin.paj', {id : id, uid : uid, action : 'edit_pub', sub : '00'}, function(data){

			jQuery('.pub-list-item').removeClass('pub-left-active');
			jQuery('div#' + id).addClass('pub-left-active');

			jQuery('#middle-panel').html(data);
			jQuery('tr').attr('style',''); jQuery('tr#x' + id ).attr('style','color: #337ab7');
		})
	});
	jQuery(document).on('click','.list-active',function(){
		section = jQuery('#section').val();
		uid = jQuery(this).data('uid');
		id = jQuery(this).data('id');
		jQuery.post('_admin_ajax/__publicadmin.paj', {id : id, uid : uid, action : 'active'}, function(data){
			a = data * 1;
//			console.log(a);
			if (a == 1){jQuery('#' + uid).removeClass('check-passive').addClass('check-active')};
			if (a == 0){jQuery('#' + uid).removeClass('check-active').addClass('check-passive')};
		})
	});

// pub submit
	jQuery(document).on('click','#submit_pub',function(){
		var ehtml = jQuery('#summernote').summernote('code');
		jQuery('#html').val(ehtml);
		var msg = jQuery('#pubformx').serialize();
		id = jQuery('#id').val();
		uid = jQuery('#uid').val();
		jQuery.ajax({
			type: 'POST',
			url: '/admin/_admin_ajax/__publicadmin.paj',
			data: msg,
			success: function(data) {
					jQuery.post('_admin_ajax/__publicadmin.paj', {action : 'list', uid : uid, id : id}, function(data){
						jQuery('#left-content').html(data);
					})
					.done(
						jQuery.post('_admin_ajax/__publicadmin.paj', {action : 'edit_pub', uid : uid, id : id}, function(data){
							jQuery('#middle-panel').html(data)
						})
					)
			},
			error:  function(xhr, str){
				alert('Error: ' + xhr.responseCode);
			}
		});
	});