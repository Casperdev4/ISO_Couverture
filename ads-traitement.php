<?php
header('Content-Type: text/html; charset=UTF-8');

function contient_liens($texte) {
    $patternLien = "/https?:\/\/[^\s]+|<a\s+href\s*=\s*['\"]?[^\s>]+['\"]?/i";
    $patternScript = "/<script[^>]*>[\s\S]*?<\/script>/i";
    return preg_match($patternLien, $texte) || preg_match($patternScript, $texte);
}

function est_vide($champ) {
    return !isset($champ) || trim($champ) === '';
}

function contient_cyrillique($texte) {
    return preg_match("/[\p{Cyrillic}]/u", $texte);
}

function est_numero_valide($numero) {
    return preg_match('/^(06|07|\+336|\+337)\d{8}$/', $numero);
}

$nom = htmlspecialchars($_POST['nom'], ENT_QUOTES, 'UTF-8');
$telephone = htmlspecialchars($_POST['telephone'], ENT_QUOTES, 'UTF-8');
$services = htmlspecialchars($_POST['services'], ENT_QUOTES, 'UTF-8');
$commentaires = htmlspecialchars($_POST['commentaires'], ENT_QUOTES, 'UTF-8');

$errors = [];

if (est_vide($nom) || est_vide($telephone) || est_vide($services) || est_vide($commentaires)) {
    $errors[] = "Tous les champs sont obligatoires.";
}

if (!est_numero_valide($telephone)) {
    $errors[] = "Veuillez entrer un numéro de téléphone valide.";
}

if (contient_liens($commentaires) || contient_cyrillique($commentaires)) {
    $errors[] = "Pas autorisés.";
}

if (!empty($errors)) {
    echo implode('<br>', $errors);
    exit();
}

$message = "Nom : $nom \n";
$message .= "Téléphone : $telephone \n";
$message .= "Prestation : $services \n";
$message .= "Commentaires : $commentaires \n";

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

require 'PHPMailer/src/Exception.php';
require 'PHPMailer/src/PHPMailer.php';
require 'PHPMailer/src/SMTP.php';

$mail = new PHPMailer(true);

try {
    $mail->isSMTP();
    $mail->Host       = 'smtp.ionos.fr';
    $mail->SMTPAuth   = true;
    $mail->Username   = 'contact@webprime.fr';
    $mail->Password   = 'Allamlyly912!';
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
    $mail->Port       = 465;

    $mail->setFrom('contact@webprime.fr', 'ISO Couverture');
    $mail->addAddress('lisocouverture@gmail.com');
    $mail->addAddress('webprime91@hotmail.com');
    $mail->CharSet = 'UTF-8';
    $mail->isHTML(true);
    $mail->Subject = 'Formulaire';
    $mail->Body    = nl2br($message);
    $mail->AltBody = $message;

    $mail->send();

    header('Location: https://couvreurs95.fr/merci-lhhrhdhfdf.html');
    exit();
} catch (Exception $e) {
    echo "Message non envoyé. Erreur Mailer: {$mail->ErrorInfo}";
}
?>