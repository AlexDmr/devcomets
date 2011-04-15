<?php
//error_reporting(E_ALL);
header('Content-type: application/xhtml+xml; charset=UTF-8');
  if (ini_get('short_open_tag') == 1) echo "ATTENTION : short_open_tag option is activated in PHP. You must desactivate it!<br/>\n";
/* Lit le port du service WWW. */
if(isset($_REQUEST['Comet_port'])) {
  $service_port = $_REQUEST['Comet_port'];
 } else {$service_port = 9000;}

/* Lit l'adresse IP du serveur de destination */
$address = '127.0.0.1';
//$address = '172.18.15.14';

/* Construction du message pour les comets */
if(isset($_REQUEST['Comet_port'])) {
  /* Cree une socket TCP/IP. */
  $fp = fsockopen($address, $service_port, $errno, $errstr, 30);
  if (!$fp) {echo "$errstr ($errno)<br />\n";}
  if(isset($_POST['Comet_port'])) {unset($_POST['Comet_port']);}
  $ok = 0;
  $in = '';
  foreach($_POST as $cle => $val) {
   /* $tmp_var = str_replace(array("\r\n"), "\n", utf8_decode($cle));
	  $tmp_var = str_replace(array("\r", "\n"), "\n", $tmp_var);
    $tmp_val = str_replace(array("\r\n"), "\n", utf8_decode($val));
	  $tmp_val = str_replace(array("\r", "\n"), "\n", $tmp_val);*/
	  
    $tmp_var = str_replace(array("\r\n"), "\n", $cle);
	  $tmp_var = str_replace(array("\r", "\n"), "\n", $tmp_var);
    $tmp_val = str_replace(array("\r\n"), "\n", $val);
	  $tmp_val = str_replace(array("\r", "\n"), "\n", $tmp_val);
    $in .= strlen($tmp_var) . ' ' . $tmp_var . ' ' . strlen( utf8_decode($tmp_val) ) . ' ' . $tmp_val . '|';
    
    /* utf8_decode("$cle {$val}~~~~"); */
    $ok = 1;
   }
  if($ok == 0) {$in=' ';}
  if( get_magic_quotes_gpc() == true )
   {// on enlève les "\" en trop
    //echo 'coucou';
    $in = stripslashes($in);
   }
  $in = strlen( utf8_decode($in) ) . ' ' . $in;
  fwrite($fp, $in); flush(); 
    $out = '';
    while (!feof($fp)) {
      //$tmp = str_replace(array("\r\n"), "\n", fgets($fp));
	  ////$tmp = str_replace(array("\r\n"), "\n", utf8_decode(fgets($fp)));
	  ////$out .= utf8_encode( $tmp );
      //$tmp = str_replace(array("\r", "\n"), "\r\n", $tmp);
	  //$out .=  $tmp ;
	  $out .= fgets($fp);
     }
    echo $out;
  fclose($fp);
 } else {//echo "T1 : " . time() . '<br>';
         $fp = fsockopen($address, $service_port, $errno, $errstr, 30);
         if (!$fp) {echo "$errstr ($errno)<br />\n";}
		 $in = "$address 0                         ";
		 fwrite($fp, $in);
         $out = '';
		 //echo "T2 : " . time() . '<br>'; flush(); 
         while (!feof($fp)) {
	       $tmp = str_replace(array("\r\n"), "\n", utf8_decode(fgets($fp)));
           $tmp = str_replace(array("\r", "\n"), "\r\n", $tmp);
           $out .= utf8_encode( $tmp );
          }
		 //echo "T3 : " . time() . '<br>';
         echo $out;
		 fclose($fp);
		 //echo "T4 : " . time() . '<br>';
        }
//echo "Tend : " . time() . '<br>';
?>