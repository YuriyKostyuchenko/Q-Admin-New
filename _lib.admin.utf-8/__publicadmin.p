@publicadmin[p;param]

^if($p eq ""){^initPanels[400;;1;0;;]}

^if(def $form:idx){
	$cookie:idx[ 
		$.value[$form:idx]
		$.expires[session]  
	]   
}

^if(def $form:type){
	$cookie:type[ 
		$.value[$form:type]
		$.expires[session]  
	]   
}

$idx[$cookie:idx]
^if(def $idx){$idx[$cookie:idx]}{$idx[1]}

<script>
jQuery(document).ready(function() {

^if($p eq "l" || $p eq ""){ jQuery.get('_admin_ajax/__publicadmin.paj',{idx : '$idx', action : 'list', type : '$form:type'}, function(data){ ^$('#left-content').html(data) ^; })^; }
^if($p eq "m" || $p eq ""){ jQuery.get('_admin_ajax/__publicadmin.paj',{idx : '$idx', type : '$form:type', action : 'new_pub'}, function(data){^$('#middle-panel').html(data) ^; })^; }
})

</script>



