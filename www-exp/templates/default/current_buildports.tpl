<!-- $MCom: portstools/tinderbox/www-exp/templates/default/current_buildports.tpl,v 1.1.1.1.2.2 2006/01/22 01:18:16 marcus Exp $ //-->
<?if(!$no_list){?>
	<?if($build_name){?>
		<h1>Current Builds in <?=$build_name?></h1>
	<?}else{?>
		<h1>Current Builds</h1>
	<?}?>
	<table>
		<tr>
			<th>Build</th>
			<th>Port</th>
			<th>Duration</th>
		</tr>
		<?foreach($data as $row) {?>
			<tr>
				<td><a href="index.php?action=list_buildports&amp;build=<?=$row['build_name']?>"><?=$row['build_name']?></a></td>
				<td><?=$row['port_current_version']?></td>
				<td><?=time_difference_from_now($row['build_last_updated'])?></td>
			</tr>
		<?}?>
	</table>
	<script language="JavaScript">
		setTimeout("reloadpage()", 15000)
	</script>
<?}?>
