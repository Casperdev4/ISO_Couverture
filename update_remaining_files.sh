#!/bin/bash

# Liste des fichiers restants à modifier
files=(
    "couvreur-cergy.html"
    "couvreur-cormeilles-en-parisis.html"
    "couvreur-eaubonne.html"
    "couvreur-ermont.html"
    "couvreur-franconville.html"
    "couvreur-garges-les-gonesse.html"
    "couvreur-gonesse.html"
    "couvreur-goussainville.html"
    "couvreur-groslay.html"
    "couvreur-herblay-sur-seine.html"
    "couvreur-montmagny.html"
    "couvreur-montmorency.html"
    "couvreur-saint-brice.html"
    "couvreur-saint-leu-la-foret.html"
    "couvreur-sannois.html"
    "couvreur-sarcelles.html"
    "couvreur-taverny.html"
)

echo "Debut de la modification des fichiers..."

for file in "${files[@]}"; do
    echo "Traitement de $file..."

    # Sauvegarde
    cp "$file" "$file.bak"

    # Modification du tag form
    sed -i 's/<form action="https:\/\/formsubmit\.co\/formulaire@webprime\.fr" method="POST" onsubmit="return validateForm()">/<form id="contactForm" onsubmit="return submitToWebPrime(event)">/g' "$file"

    # Modification du champ honeypot
    sed -i 's/<input type="text" id="website" name="website" autocomplete="off">/<input type="text" id="website" name="_gotcha" autocomplete="off">/g' "$file"

    # Suppression des champs cachés inutiles
    sed -i '/<input type="hidden" name="_next"/d' "$file"
    sed -i '/<input type="hidden" name="_cc"/d' "$file"
    sed -i '/<input type="hidden" name="_template"/d' "$file"
    sed -i '/<input type="hidden" name="_blacklist"/d' "$file"

    # Modification du label Telephone
    sed -i 's/<label for="tel">Téléphone :<\/label>/<label for="tel">Telephone :<\/label>/g' "$file"

    # Modification du nom du champ telephone
    sed -i 's/name="telephone"/name="tel"/g' "$file"

    # Ajout du champ email après le téléphone
    sed -i '/<label for="tel">Telephone :<\/label>/a\                <input type="tel" id="tel" name="tel" pattern="^((\\+33|0)[1679])[0-9]{8}$" maxlength="12" required>\n                <label for="email">Email :<\/label>\n                <input type="email" id="email" name="email" required>' "$file"

    # Suppression de la ligne telephone dupliquée
    sed -i '/<label for="tel">Telephone :<\/label>/{n;d;}' "$file"

    # Modification de RAVALEMENT DE FAÇADE vers RAVALEMENT DE FACADE
    sed -i 's/RAVALEMENT DE FAÇADE/RAVALEMENT DE FACADE/g' "$file"

    # Suppression de required sur le textarea
    sed -i 's/<textarea id="comments" name="commentaires" rows="4" required>/<textarea id="comments" name="commentaires" rows="4">/g' "$file"

    # Ajout du script avant </body>
    if ! grep -q "submitToWebPrime" "$file"; then
        sed -i 's/<\/body>/    <script>\nasync function submitToWebPrime(e) {\n    e.preventDefault();\n    var form = document.getElementById('\''contactForm'\'');\n    var btn = form.querySelector('\''button[type="submit"]'\'');\n    var originalText = btn.textContent;\n\n    if (form._gotcha \&\& form._gotcha.value) return false;\n\n    btn.textContent = '\''Envoi en cours...'\'';\n    btn.disabled = true;\n\n    try {\n        var formData = new FormData(form);\n        var response = await fetch('\''https:\/\/webprime.app\/webhook\/contact\/930ce709a49b4c927f6c05614f0c6e254ba4dda9c40d1f0392b5036d5f5796a6'\'', {\n            method: '\''POST'\'',\n            body: formData\n        });\n\n        if (response.ok) {\n            window.location.href = '\''https:\/\/iso-couvreur-95.fr\/'\'';\n        } else {\n            alert('\''Erreur lors de l\\'\''envoi. Veuillez reessayer.'\'');\n            btn.textContent = originalText;\n            btn.disabled = false;\n        }\n    } catch (error) {\n        alert('\''Erreur de connexion. Veuillez reessayer.'\'');\n        btn.textContent = originalText;\n        btn.disabled = false;\n    }\n    return false;\n}\n<\/script>\n<\/body>/g' "$file"
    fi

    echo "✓ $file modifié"
done

echo "Toutes les modifications sont terminées!"
