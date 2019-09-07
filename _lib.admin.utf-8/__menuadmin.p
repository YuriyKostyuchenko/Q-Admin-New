# Q-Admin v:5.0.1 (http://qservice.ws) # Copyright 2004-2015 Q-Service # Licensed under MIT # 2015.12.20 (2004.03.12) #
@menuadmin[]

^if($form:idx ne ""){
	$cookie:idx[$form:idx]
}{
	$cookie:idx[1]
}

<script type="text/javascript" src="_includes/jstree-3.2.1/dist/jstree.js"></script>
<link rel="stylesheet" href="_includes/jstree-3.2.1/dist/themes/default/style.min.css" />
		<style>
		#container { min-width:320px; margin:0px auto 0 auto; background:white; border-radius:0px; padding:0px; overflow:hidden; }
		#tree { float:left; min-width:319px; border-right:1px solid silver; overflow:auto; padding:0px 0; }
		#data { margin-left:320px; }
		#data textarea { margin:0; padding:0; height:100%; width:100%; border:0; background:white; display:block; line-height:18px; resize:none; }
		#data, #code { font: normal normal normal 12px/18px 'Consolas', monospace !important; }

		#left-content .folder { background:url('_includes/jstree-3.2.1/dist/themes/folder.png') no-repeat; }
		#left-content .file { background:url('_includes/jstree-3.2.1/dist/themes/file.png') 0 0 no-repeat; }
		
		</style>

<link rel="stylesheet" type="text/css" href="_includes/style.css" />



^connect[$CONNECT]{
$admin_set[^table::sql{select * from ${BASEBOSS}admin_set where id = "1000"}] 
$cataloque_id[^string:sql{SELECT id FROM ${BASE}structure WHERE pub_link = 'cataloque'}[$.limit(1) $.default{0}]]
$cataloque_idx[^string:sql{SELECT idx FROM ${BASE}structure WHERE pub_link = 'cataloque'}[$.limit(1) $.default{0}]]
$childMax[^string:sql{SELECT childMax FROM ${BASE}structure WHERE pub_link = 'cataloque'}[$.limit(1) $.default{0}]]
}
#$cookie:jstree_select[$.value[] $.expires[]]
#$cookie:jstree_open[$.value[] $.expires[]]
^if(def $form:pos){$cookie:pos[$.value[$form:pos] $.expires[session]]}
$pos[$cookie:pos]
^if(def $pos){$pos[$cookie:pos]}{$pos[1]}
^if(def $num_menu){}{$num_menu[1]}
^if(def $form:pos){$num_menu[$form:pos]}



$serverside[_server.json]
^if($cataloque_id ne "0" && $cataloque_idx eq $pos){$serverside[_cataloques.paj]}


<div id="middle-panel" style="visibility:visible"><textarea id="elm1" name="elm1"  rows="300" style="width: 100%; height: 100%" class="tinymce"></textarea></div>
<div id="left-panel-closed" style="visibility: hidden">
	<div id="left-panel-arr" class="arr-close" ></div>
</div>
<div id="right-panel-closed" style="visibility:hidden">
	<div id="right-panel-arr" class="r-arr-close"></div>
</div>
<div id="left-panel" >
	<div id="left-switcher">
		<div id="left-panel-arr" class="arr-open"></div>
		<div id="left-switcher-txt">Menu</div>
	</div>
	<div id="left-idx"></div>
	<div id="left-flags"></div>
	<div id="left-content">Loading...</div>
	<div id="lll"></div>
</div>
<div id="right-panel" >
	<div id="right-switcher">
		<div id="right-panel-arr" class="r-arr-open"></div>
		<div id="right-switcher-txt">Свойства</div>
	</div>
	<div id="right-content"></div>
</div>
<input type=hidden id="result">
# for preffix d&d tiny
<input id="node_id" type="text" value="">
##### Main menu & Edit


<script type="text/javascript">
	jQuery(function () {
		jQuery(window).resize(function () {
			var h = Math.max(jQuery(window).height() - 0, 420);
			jQuery('#container, #data, #left-content, #data .content').height(h).filter('.default').css('lineHeight', h + 'px');
		}).resize();

		jQuery('#left-content')
		.jstree({
			'core' : {
				'data' : {
					'url' : '/admin/_server.json?operation=get_node',
					'dataType' : 'json',
					'data' : function (node) {
						jQuery('#node_id').val(node.id);
							return { 'id' : node.id, 'idx': '$cookie:idx' };
						}
					},
				'check_callback' : true,
				'themes' : {
					'responsive' : false,
					'stripes' : true
				}
			},
			'force_text' : true,
			'plugins' : ['state','dnd','contextmenu'],
			'contextmenu' : { 
				'items' : customMenu
			}
		})
		.on('delete_node.jstree', function (e, data) {
			jQuery.get('/admin/_server.json?operation=delete_node', { 'id' : data.node.id })
			.fail(function () {
				data.instance.refresh();
			})
		})
		.on('create_node.jstree', function (e, data) {
			jQuery.get('/admin/_server.json?operation=create_node', { 'id' : data.node.parent, 'idx' : '$cookie:idx', 'position' : data.position, 'text' : data.node.text })
			.done(function (d) {
				idr = d.replace(/\D/g, '');
				data.instance.set_id(data.node, idr);
				data.instance.redraw_node(data.node.a_attr.id, idr);
				data.instance.edit(idr);
			})
			.fail(function () {
				data.instance.refresh();
			})
		})
		.on('rename_node.jstree', function (e, data) {
			dni = data.node.id
			dni = dni.replace(/\D/g, '')
			jQuery.get('/admin/_server.json?operation=rename_node', { 'id':dni,'text' : data.text })
			.fail(function () {
				data.instance.refresh();
			})
			.done(function (d) { data.instance.refresh(); })
		})
		.on('move_node.jstree', function (e, data) {
			jQuery.get('/admin/_server.json?operation=move_node', { 'id' : data.node.id, 'parent' : data.parent, 'position' : data.position })
			.fail(function () {
				data.instance.refresh();
			});
		})
		.on('copy_node.jstree', function (e, data) {
			jQuery.get('/admin/_server.json?operation=copy_node', { 'id' : data.original.id, 'parent' : data.parent, 'position' : data.position })
			.always(function () {
				data.instance.refresh();
			})
		})
		.on('changed.jstree', function (e, data) {
			if(data && data.selected && data.selected.length) {
				jQuery.get('/admin/_server.json?operation=get_node&idx=$cookie:idx&id=' + data.selected.join(':'), function (d) {
						jQuery('#data .default').html(d.content).show();
				});
			}
			else {
				jQuery('#data .content').hide();
				jQuery('#data .default').html('Select a file from the tree.').show();
			}
		})
	});
	function customMenu(node) {
		if (jQuery('li#'+node.id).hasClass('jstree-closed') || jQuery('li#'+node.id).hasClass('jstree-open')) { //If node is a folder
			var renameLabel = 'Rename Folder';
		} else { 
			var renameLabel = 'Rename File';
		}
		return { 
			'create' : {
				'separator_before' : false,
				'separator_after' : true,
				icon: 'fa fa-plus',
				'label' : '$_t._create',
				'action': function (data) {
					var ref = jQuery.jstree.reference(data.reference);
					sel = ref.get_selected();
					if(!sel.length) { return false; }
					sel = sel[0];
					sel = ref.create_node(sel, {'type':'file'});
					if(sel) { ref.edit(sel); }
				}
			},
			'rename' : {
				'separator_before' : false,
				'separator_after' : false,
				icon: 'fa fa-edit',
				'label' : '$_t._rename',
				'action' : function (data) { 
					var inst = jQuery.jstree.reference(data.reference);
					obj = inst.get_node(data.reference);
					inst.edit(obj); 
				}
			},
			'remove' : {
				'separator_before' : false,
				icon: 'fa fa-trash-alt',
				'separator_after' : false,
				'label' : '$_t._delete',
				'action': function (data) {
					var ref = jQuery.jstree.reference(data.reference),
					sel = ref.get_selected();
					if(!sel.length) { return false; }
					ref.delete_node(sel);
					jQuery('#left-content').jstree(true).refresh();
				}
			},
			'reserve': {
				label: 'Reserve',
				action: function (node) { 
					alert('Should launch here.')
				},
				seperator_after: false,
				seperator_before: false
			},
			'secret' : { 
				id : 'secret',
				label : 'Secret',
				icon : 'fa fa-user-secret',
				action : function (data){
					secr = prompt( '  ' );
					var inst = jQuery.jstree.reference(data.reference);
					obj = inst.get_node(data.reference);
					dni = obj.id.replace(/\D/g, '');
					jQuery.get('_admin_ajax/_item_set_act_secret.paj',{ 'id':dni,'secret': secr}); 
					jQuery('#left-content').jstree(true).refresh();
					jQuery.get('/admin/_admin_ajax/_flags.paj?id=' + dni, function(data) {jQuery('#left-flags').html(data);});
				}
			},
			'visitable' : { 
				id : 'visiable',
				label : 'Visible/Hidden',
				icon : 'fa fa-eye-slash',
				action : function (data) { 
					var inst = jQuery.jstree.reference(data.reference);
					obj = inst.get_node(data.reference);
					dni = obj.id.replace(/\D/g, '');
					jQuery.get('_admin_ajax/_item_visible-hidden.paj',{id: dni}); 
					jQuery('#left-content').jstree(true).refresh();
					jQuery.get('/admin/_admin_ajax/_flags.paj?id=' + dni, function(data) {jQuery('#left-flags').html(data);});
				}
			},
			'woutdoc' : { 
				id : 'woutdoc',
				label : 'Without a document',
				icon : 'fa fa-file',
				action : function (data) {
					var inst = jQuery.jstree.reference(data.reference);
					obj = inst.get_node(data.reference);
					dni = obj.id.replace(/\D/g, '');
					jQuery.get('_admin_ajax/_item_set_act_cont.paj',{id: dni}); 
					jQuery('#left-content').jstree(true).refresh();
					jQuery.get('/admin/_admin_ajax/_flags.paj?id=' + dni, function(data) {jQuery('#left-flags').html(data);});
				}
			},
			'bannerl' : { 
				id : 'bannerl',
				label : 'Banner Link',
				icon : 'fa fa-flag',
				action : function (data) {
					var inst = jQuery.jstree.reference(data.reference);
					obj = inst.get_node(data.reference);
					dni = obj.id.replace(/\D/g, '');
					jQuery.get('_admin_ajax/_banner_ref.paj',{id: dni}, 
					function(data) { jQuery('#middle-panel_parent').css('display','none')^; 
					jQuery('#middle-panel').css('display','').html(data);}); 
				}
			},
			'gohref' : { 
				id : 'go_href',
				label : 'HREF Link',
				icon : 'fa fa-share-square',
				action : function (data) {
					var inst = jQuery.jstree.reference(data.reference);
					obj = inst.get_node(data.reference);
					dni = obj.id.replace(/\D/g, '');
					jQuery.get('_admin_ajax/_item_gohref.paj', {id: dni, action: 'gethref'}, function(data) {
						jQuery('#result').val(data);
						var gh=jQuery('#result').val();
						ihref = prompt('http://',gh);
						if(ihref || ihref  == ''){
							jQuery.get('_admin_ajax/_item_gohref.paj',{id: dni, action: 'gohref', gohref: ihref});
						};
						jQuery.get('/admin/_admin_ajax/_flags.paj?id=' + dni, function(data) {jQuery('#left-flags').html(data);});
					}); 
					jQuery('#left-content').jstree(true).refresh();
				}
			},
			'menuimg' : {
				id : 'menuimg',
				label : 'Image Link',
				icon : 'fa fa-image',
				action : function (data) {
					var inst = jQuery.jstree.reference(data.reference);
					obj = inst.get_node(data.reference);
					dni = obj.id.replace(/\D/g, '');
					jQuery.get('_admin_ajax/_item_menuimg.paj', {id: dni, action: 'getmenuimg'}, function(data) {
						jQuery('#result').val(data);
						var gi=jQuery('#result').val();
						iimg = prompt('http://',gi);
						if(iimg || iimg == ''){
							jQuery.get('_admin_ajax/_item_menuimg.paj',{id: dni, action: 'setmenuimg', img: iimg});
						};
						jQuery.get('/admin/_admin_ajax/_flags.paj?id=' + dni, function(data) {jQuery('#left-flags').html(data);});
					}); 
					jQuery('#left-content').jstree(true).refresh();
				}
			},
			'lock' : { 
				id : 'lock',
				label : 'Lock/Unlock',
				icon : 'fa fa-lock',
				action : function (data) {
					var inst = jQuery.jstree.reference(data.reference);
					obj = inst.get_node(data.reference);
					dni = obj.id.replace(/\D/g, '');
					jQuery.get('_admin_ajax/_item_set_lock-unlock.paj',{id: dni})^; 
					jQuery('#left-content').jstree(true).refresh();
					jQuery.get('/admin/_admin_ajax/_flags.paj', {id: dni}, function(data) {jQuery('#left-flags').html(data)^;})^;
				}
			}
		}
	};
###########
	jQuery('#left-content').on('click', 'a', function(){
		jQuery('#middle-panel').css('visibility','');
		var nodeid = jQuery(this).parent('li').attr('id');
		id = nodeid.replace('node_','');
		jQuery.get('_admin_ajax/_flags.paj?id=' + id, function(data) {
			jQuery('#left-flags').html(data);
		});

		jQuery.get('$serverside',{id: nodeid, operation: 'loadfile', idx: '$cookie:idx'}, function(data) {
			jQuery.cookie('jstree_select', nodeid);
			tinyMCE.get('elm1').setContent(data);
		//		jQuery('#elm1').val();
		//		jQuery('#elm1').tinymce().execCommand('mceSetContent',true, data );
				
			return false;
		});
		jQuery.get('_admin_ajax/_menu_pref_panel.paj?id=' +id , function(data) {
			jQuery('#right-content').html(data);
		})
	});
</script>


#################### Setup TinyMCE 
<script type="text/javascript" src="_includes/tinymce_5.0.15/js/tinymce/tinymce.min.js"></script>

<script type="text/javascript">
tinymce.init({
	selector: 'textarea.tinymce',
	theme: 'silver',
	language: '$cookie:loc', //uk, hu, en, ru
	extended_valid_elements : 'a[class|name|href|target|title|onclick|rel],script[type|src],iframe[src|style|width|height|scrolling|marginwidth|marginheight|frameborder],img[class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name],$elements',
	height: 500,
	plugins: [
		'save advlist autolink link image lists charmap print preview hr anchor pagebreak spellchecker ' +
		'searchreplace wordcount visualblocks visualchars code fullscreen insertdatetime media nonbreaking ' +
		'table contextmenu directionality emoticons template paste textcolor imagetools responsivefilemanager'
	],

#	menubar: 'view format',
#	toolbar: 'save code paste insertfile undo redo | bold italic removeformat | alignleft aligncenter alignright alignjustify table | bullist numlist outdent indent | link image media | print preview fullpage | forecolor backcolor', 
	toolbar: 'save code paste searchreplace undo redo | bold italic removeformat | alignleft aligncenter alignright alignjustify table | bullist numlist outdent indent | link image media responsivefilemanager | preview ', 

	external_filemanager_path:'/admin/filemanager/',
	filemanager_title:'Responsive Filemanager' ,
	external_plugins: { 'filemanager' : '/admin/filemanager/plugin.min.js'},

	visualblocks_default_state: false,
	paste_data_images: true,
	images_upload_url: '$serverside',
	images_reuse_filename: true,
	images_upload_handler: function (blobInfo, success, failure) {
		var page_id = jQuery('#node_id').val();
		var xhr, formData;

		xhr = new XMLHttpRequest();
		xhr.withCredentials = false;
		xhr.open('POST', '$serverside');
		
		xhr.onload = function() {
			var json;
			if (xhr.status != 200) {
				failure('HTTP Error: ' + xhr.status);
				return;
			}

			json = JSON.parse(xhr.responseText);

			if (!json || typeof json.location != 'string') {
				failure('Invalid JSON: ' + xhr.responseText);
				return;
			}

			success(json.location);
		};

		formData = new FormData();
		formData.append('file', blobInfo.blob(), blobInfo.filename());
		formData.append('id', page_id);
		formData.append('operation', 'image_upload');

		xhr.send(formData);
	},
	content_css: ['/admin/_includes/bootstrap-4.3.1-dist/css/bootstrap.min.css', '/css/theme.css'],

	save_enablewhendirty: true,
	save_onsavecallback: function() {
		itemContent = tinyMCE.activeEditor.getContent();
		jQuery.ajax({
			url: '$serverside',
			type: 'POST',
			data: { 
				operation : 'savefile', 
				data : itemContent,  
				id : jQuery.cookie('jstree_select')
			}
		})
	}
}); 
</script>






<script> 
function epvisible(){
jQuery('#editor-panel').css('visibility','visible');
};

jQuery('textarea.tynymce').each(function() {
this.tinymce().hide();
});
jQuery('#editor-panel').css('visibility','hidden')
</script>

<script>
jQuery('div').on('click', '.arr-open', function(){
	var dvis=jQuery('#left-panel').css('visibility');
#	alert(dvis);
	if(dvis == 'visible'){
		jQuery('#left-panel').css('visibility','hidden');
		jQuery('#middle-panel').css('left', '35px');
		jQuery('#left-panel-closed').css('visibility','visible');
	}
});

jQuery('div').on('click', '.arr-close', function(){
       	var dvis=jQuery('#left-panel').css('visibility');
	if(dvis == 'hidden'){
		jQuery('#left-panel').css('visibility','visible');
		jQuery('#middle-panel').css('left', '265px');
		jQuery('#left-panel-closed').css('visibility','hidden');

	}
});

jQuery('div').on('click', '.r-arr-open', function(){
	var dvis=jQuery('#right-panel').css('visibility');
#	alert(dvis);
	if(dvis == 'visible'){
		jQuery('#right-panel').css('visibility','hidden');
		jQuery('#middle-panel').css('right', '35px');
		jQuery('#right-panel-closed').css('visibility','visible');
	}
});

jQuery('div').on('click', '.r-arr-close', function(){
	var dvis=jQuery('#right-panel').css('visibility');
	if(dvis == 'hidden'){
		jQuery('#right-panel').css('visibility','visible');
		jQuery('#middle-panel').css('right', '265px');
		jQuery('#right-panel-closed').css('visibility','hidden');

	}
});



clickedId = jQuery('#left-content a .jstree-clicked').parent('li').attr('id');

jQuery.get('_admin_ajax/_idx_panel.paj', {operations : 'addPanel', idx : '$cookie:idx'}, function(data) {jQuery('#left-idx').html(data); });

</script>


