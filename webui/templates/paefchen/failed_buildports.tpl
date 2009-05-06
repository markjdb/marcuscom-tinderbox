<?php 
$topmenu = array();
$header_title = $build_name
	? "Build Failures in $build_name"
	: "All Build Failures";
if ($maintainer)
	$header_title .= " for $maintainer";
if ($reason)
	$header_title = "Build by reason: $reason";
include 'header.inc.tpl';
?>
<!-- $Paefchen: FreeBSD/tinderbox/webui/templates/paefchen/failed_buildports.tpl,v 1.1 2008/01/05 12:25:17 as Exp $ //-->
<?php if($errors){?>
	<p style="color:#FF0000">
	<?php foreach($errors as $error){?>
		<?php echo $error?><br />
	<?php }?>
	</p>
<?php }?>
<?php if(!$no_list){?>
<table>
	<tr>
		<th>Build</th>
		<th>Port Directory</th>
		<th>Version</th>
		<th style="width: 20px">&nbsp;</th>
		<th>Reason</th>
		<th>&nbsp;</th>
		<th>Last Build Attempt</th>
		<th>Last Successful Build</th>
	</tr>
<?php foreach($data as $row) {?>
	<tr>
		<td><a href="index.php?action=list_buildports&amp;build=<?php echo $row['build_name']?>"><?php echo $row['build_name']?></a></td>
		<td><a href="index.php?action=describe_port&amp;id=<?php echo $row['port_id']?>"><?php echo $row['port_directory']?></a></td>
		<td><?php echo $row['port_last_built_version']?></td>
		<td class="<?php echo $row['status_field_class']?>"><?php echo $row['status_field_letter']?></td>
		<?php $reason=$row['port_last_fail_reason']?>
		<td class="<?php if(!empty($reason)) echo "fail_reason_".$port_fail_reasons[$reason]['type']?>">
		<?php $href=isset($port_fail_reasons[$reason]['link']) ? "index.php?action=display_failure_reasons&amp;failure_reason_tag=$reason#$reason" : "#"?>
		<a href="<?php echo $href?>" class="<?php if(!empty($reason)) echo "fail_reason_".$port_fail_reasons[$reason]['type']?>" title="<?php if(!empty($reason)) $port_fail_reasons[$reason]['descr']?>"><?php echo $reason?></a>
		</td>
		<td>
	<?php if($row['port_link_logfile']){?>
		<a href="<?php echo $row['port_link_logfile']?>">log</a>
		<a href="index.php?action=display_markup_log&amp;build=<?php echo $row['build_name']?>&amp;id=<?php echo $row['port_id']?>">markup</a>
	<?php }?>
	<?php if($row['port_link_package']){?>
			<a href="<?php echo $row['port_link_package']?>">package</a>
	<?php }?>
		</td>
		<td><?php echo $row['port_last_built']?></td>
		<td><?php echo $row['port_last_successful_built']?></td>
	</tr>
<?php }?>
</table>
<p>
  <?php if($list_nr_prev!=-1){?>
	  <a href="index.php?action=<?php echo $_REQUEST['action'] ?>&build=<?php if (isset($_REQUEST['build']))echo $_REQUEST['build'] ?>&reason=<?php if (isset($_REQUEST['reason']))echo $_REQUEST['reason'] ?>&maintainer=<?php if (isset($maintainer))echo $maintainer ?>&list_limit_offset=<?php echo $list_nr_prev ?> ">prev</a>  
  <?php }?>
  <?php if($list_nr_next!=0){?>
	  <a href="index.php?action=<?php echo $_REQUEST['action'] ?>&build=<?php if (isset($_REQUEST['build']))echo $_REQUEST['build'] ?>&reason=<?php if (isset($_REQUEST['reason']))echo $_REQUEST['reason'] ?>&maintainer=<?php if (isset($maintainer))echo $maintainer ?>&list_limit_offset=<?php echo $list_nr_next ?> ">next</a>
  <?php }?>
</p>
<?php }else{?>
<?php if(!$errors){?>
	<p>There are no build failures at the moment.</p>
<?php }?>
<?php }
$footer_legend = array(
	'port_success'	=> 'Success',
	'port_default'	=> 'Default',
	'port_leftovers'=> 'Leftovers', # L 
	'port_dud'		=> 'Dud', # D 
	'port_depend'	=> 'Depend',
	'port_fail'		=> 'Fail',
);
include 'footer.inc.tpl';
?>
