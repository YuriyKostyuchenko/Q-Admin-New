@adminnav_top[]
^connect[$CONNECT]{
$manag[^table::sql{SELECT * FROM ${BASE}admins WHERE login = "$cookie:user"}]
^if(-f "/_qadminMenu.cfg"){
	$sections[^table::load[nameless;/_qadminMenu.cfg]]
	}{
	$sections[^table::load[nameless;/admin/_qadminMenu.cfg]]
	}
$admin_rights[^string:sql{select rights from ${BASE}admins where login="$cookie:user"}]
$admin_set[^table::sql{select * from ${BASEBOSS}admin_set where id=1000}]
}



<nav class="navbar fixed-top navbar-expand-lg navbar-light bg-light">
	<a class="navbar-brand" href="#" style="color:red">QAdmin<sup>®</sup></a>
	<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
		<span class="navbar-toggler-icon"></span>
	</button>
	<div class="collapse navbar-collapse" id="navbarSupportedContent">
		<ul class="navbar-nav mr-auto" style="width:100%">
			$cnt(1)
			$sub[0]
			^sections.menu{
				$nextLine(^eval(^sections.offset[] + 1))
				^sections.offset(1)
				$nextRow[$sections.0]
				^sections.offset(-1)
#				^if($sections.0 eq "["){<div class="dropdown-menu" aria-labelledby="navbarDropdown">}
				^if($sections.0 eq "]"){</div></li>}
				^if($sections.0 ne "[" && $sections.0 ne "]"){
					^if($sections.0 eq "#"){}{
						^connect[$CONNECT]{$thisuser[^table::sql{select * from ${BASE}admins where login = "$cookie:user"}]}
#						^if($thisuser.active eq "9" || ^thisuser.rights.match[$sections.0]){
							^if($sections.0 eq "~"){
								<li class="nav-item dropdown">
									<a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">^process{^untaint{$sections.1}}</a>
										<div class="dropdown-menu" aria-labelledby="navbarDropdown">
										$sub[1]
								}
							^if($sections.0 eq "]"){$sub[0]</div></li>}


							^if($sections.0 ne "~" && $sections.0 ne "]" && $sections.0 ne "["){
								^if($sub eq "1"){<a class="dropdown-item" href="index.html?applet=$sections.0">^process{^untaint{$sections.1}}</a>
								}{
								<li class="nav-item">$n(^manag.admin_right.match[$sections.0][n]) 
									^if($n != 0 || $thisuser.active eq "9"){
										<a class="nav-link" href="index.html?applet=$sections.0">^process{^untaint{$sections.1}}</a>
									}{
										><a style="color:#bbb^;">^process{^untaint{$sections.1}}</a>
									}
								}
#								^if($nextRow eq "["){;</li>}
							}
							^cnt.inc[]
						}
#					}
				}
			}
			^if($manag.temporary_password eq "1"){<li class="nav-item"><a class="nav-link" style="color:red" href="/admin/___reforgot.html">$_t._pass_change</a></li>}
			<li class="nav-item"><a class="nav-link" href="../">$_t._home</a></li> 
			<li class="nav-item"><a class="nav-link" href="index.html?logout=1">$_t._esc</a></li>
		</ul>
		$localizations[^file:list[/admin/_localization;\.loc^$]]
		<ul class="navbar-nav mr-auto" id="rmenu">
			<li class="nav-item dropdown">
				<a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">$al[^admin_set.admin_lang.left(2)]^al.upper[]</a>
					<div class="dropdown-menu" aria-labelledby="navbarDropdown">
					^localizations.menu{
						$lname[${admin_set.admin_lang}.loc]
						$locname[^localizations.name.match[(.loc)][]{}]
						^if($lname eq $localizations.name){}{
							<a class="dropdown-item" style="cursor:pointer^;right:0^;width: auto"onclick="javascript: 
							jQuery.get('/admin/_admin_ajax/_change_loc.paj', {loc : '$locname'}, function(){document.cookie='loc=$locname' ^; window.location.href='index.html?loc=$locname'})^;
							return true^;
							">$ln[^localizations.name.left(2)]^ln.upper[]</a>
						}
					}
					</div>

			</li>
		</ul>

	</div>
</nav>



$admin_set[^table::sql{select * from ${BASEBOSS}admin_set where id = "1000"}] 
<script>
	jQuery('img.but').click(function(){ 
				document.location.href = 'index.html?applet=pref&a=' + this.id ^;
	})^;
</script>
