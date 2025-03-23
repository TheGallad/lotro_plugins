import "PimpYourText.Utils.UTF";

_G.InitTranslation = function()
    Lang = 2;
    if Turbine.Shell.IsCommand("hilfe") then
        Lang = 2;
    elseif Turbine.Shell.IsCommand("aide") then
        Lang = 1;
    end
end

_G.TranslateText = function(index, l)
    local p = l or Lang;
    return STRINGS[index][p];
end

function _TEST(index, word)
    for k, value in pairs(STRINGS[index]) do
        if (value == word) then return true; end
    end
    return false;
end

STRINGS = {
    ["HELP"] = { "PimpYourText\nPas d'aide (pas le temps :D)\n", "PimpYourText\nNothing here (no time, sorry :D)\n" },
    ["RESET"] = { "Réinitialiser", "Reset" },
    ["SAVE"] = { "Sauvegarder", "Save" },
    ["COLOR"] = { "Couleur :", "Color :" },
    ["CHANNEL"] = { "Canal :", "Channel :" },
    ["SENDMESSAGE"] = { "Envoyer le message", "Send your message" },
    ["SAVE_OK"] = { "<rgb=#FF5CCD>PimpYourText: Préférences sauvegardées</rgb>", "<rgb=#FF5CCD>PimpYourText: Settings saved</rgb>" },
    ["HIDE"] = { "<rgb=#FF5CCD>Fermeture de PimpYourText. Pour le r\195\169ouvrir, tapez la commande /PimpYourText show !</rgb>", "<rgb=#FF5CCD>Hiding PimpYourText. Type the following command to show again : /PimpYourText show !</rgb>" },
    ["CONFIG1"] = { "Configuration du lanceur :", "Launcher configuration :" },
    ["CONFIG_DEFAULT"] = { "Configuration par défaut", "Default configuration" },
    ["CONFIG_MOUSE"] = { "Permettre le déplacement à la souris", "Allow moving launcher with mouse" },
    ["CONFIG_SHOWLAUNCHER"] = { "Afficher un lanceur rapide", "Show a quick launcher" },
    ["CONFIG_SHOWWINDOW"] = { "Ouvrir la fenêtre principale au lancement", "Open the main window at launch" },
    ["CONFIG_ANIMATE"] = { "Animer le lanceur rapide", "Animate the quick launcher" },
    ["CONFIG_OPACITY"] = { "Opacit\195\169 du lanceur :", "Launcher opacity" },
    ["ERROR_DEST"] = { "<rgb=#FF0000>PimpYourText ERREUR: Le destinataire n'est pas saisi !</rgb>", "<rgb=#FF0000>PimpYourText ERROR: Please type a addressee !</rgb>" },
    ["ERROR_6DIGIT"] = { "<rgb=#FF0000>PimpYourText ERREUR: La couleur personnalisée doit être saisie avec 6 digits !</rgb>", "<rgb=#FF0000>PimpYourText ERROR: Custom color should have 6 digits !</rgb>" },
    ["ERROR_NOTHEXA"] = { "<rgb=#FF0000>PimpYourText ERREUR: Un des digit de la couleur personnalisée n'est pas un caractère hexadécimal valide.</rgb>", "<rgb=#FF0000>PimpYourText ERROR: One of the digit of the custom color is not a valid hexa value</rgb>" },
    ["COLOR_DEF"] = { "Par d\195\169faut", "Default" },
    ["COLOR_W"] = { "Blanc", "White" },
    ["COLOR_R"] = { "Rouge", "Red" },
    ["COLOR_Y"] = { "Jaune", "Yellow" },
    ["COLOR_G"] = { "Vert", "Green" },
    ["COLOR_B"] = { "Turquoise", "Lime Blue" },
    ["COLOR_P"] = { "Rose", "Pink" },
    ["COLOR_GO"] = { "Or", "Gold" },
    ["COLOR_GR"] = { "Gris", "Grey" },
    ["COLOR_V"] = { "Violet", "Purple" },
    ["COLOR_<3"] = { "Arc-En-Ciel", "Rainbow" },
    ["COLOR_X"] = { "Couleur RGB", "RGB color" },
    ["TAB_UP"] = { "Permet de changer d'onglet", "Change the tab to the next" },
    ["TAB_DOWN"] = { "Permet de changer d'onglet", "Change the tab to the previous" },
    ["RESET_BTN"] = { "Vide le champ de saisie de texte.", "Clear the text fields." },
    ["SAVE_BTN"] = { "Enregistre le texte, le canal et la couleur de cet onglet pour les recharger au prochain lancement.", "Save the text, the channel and the color of this tab to reload them at next launch." },
    ["CTAG1_BTN"] = { "Ajouter une balise de couleur", "Add a color tag" },
    ["CTAG2_BTN"] = { "Ajoute dans le texte une balise de couleur de la forme <rgb=#FFFFFF> (où FFFFFF est le code hexadécimal de la couleur choisie). La couleur séléctionnée sera appliquée à partir de la position du curseur.", "Add in the text a color tag like <rgb=#FFFFFF> (where FFFFFF is the hexadecimal code of the selected color). The selected color will be applied from the cursor position." },
    ["CFTAG1_BTN"] = { "Balise de fin de couleur", "Tag : End of color" },
    ["CFTAG2_BTN"] = { "Ajoute dans le texte une balise </rgb> pour ne plus appliquer de couleurs. A partir de la position du curseur, le texte reprendra la couleur par défaut du chat.", "Add in the text an end of color tag </rgb>. From the cursor position, le texte will have your chat default color." },
    ["UTAG1_BTN"] = { "Ajouter une balise pour souligner", "Add an underline tag" },
    ["UTAG2_BTN"] = { "Ajoute dans le texte une balise pour souligner le texte <u>. Le soulignement sera appliquée à partir de la position du curseur.", "Add in the text an underline tag <u>. The text will be underlined from the cursor position." },
    ["UFTAG1_BTN"] = { "Balise de fin de soulignement", "Tag : End of underline" },
    ["UFTAG2_BTN"] = { "Ajoute dans le texte une balise </u> pour ne plus appliquer le soulignement. A partir de la position du curseur, le texte ne sera plus souligné.", "Add in the text an end of underline tag </u>. From the cursor position, le texte will no longuer be underlined." },
    ["RTAG1_BTN"] = { "Supprimer toutes les balises", "Remove all tags" },
    ["RTAG2_BTN"] = { "Supprime toutes les balises dans le texte (couleurs et soulignement).", "Remove all tags in the text (colors and underlines)." },
    ["CONFIG_BTN"] = { "Changer la configuration du plugin.", "Edit configuration." },
    ["REMOVECOLOR_BTN"] = { "Retirer cette couleur de la série.", "Remove this color from the list." },
    ["CLOSECOLOR_BTN"] = { "Annuler le changement de couleur.", "Cancel the color change." },
    ["DEFAULT_TXT"] = { "Insérez ici votre texte à envoyer", "Type here the text to send" },
    ["TAG_BTN"] = { "Rajoute dans le texte (à la position du curseur) une balise de changement de couleur.\nLa couleur correspond à celle séléctionnée dans le menu déroulant des couleurs.", "Add in the text (at cursor position) a color tag.\nThe color is the one selected in the color dropdown." },
    ["ERROR_COLOR1"] = { "<rgb=#FF5CCD>ERREUR : L'ajout de balise de couleur ne peut fonctionner avec le mode Arc-En-Ciel !</rgb>", "<rgb=#FF5CCD>ERROR : Adding a tab is not possible with the Rainbow color</rgb>" },
    ["ERROR_COLOR2"] = { "<rgb=#FF5CCD>L'ajout de balise de couleur ne peut fonctionner avec la couleur par défaut !</rgb>", "<rgb=#FF5CCD>ERROR : Adding a tab is not possible with the Default color</rgb>" },
    ["CHANNEL_TALK"] = { "Parler", "Talk" },
    ["CHANNEL_COMM"] = { "Communaut\195\169", "Fellowship" },
    ["CHANNEL_CONF"] = { "Confr\195\169rie", "Kinship" },
    ["CHANNEL_RAID"] = { "Raid", "Raid" },
    ["CHANNEL_WORLD"] = { "Monde", "World" },
    ["CHANNEL_OFF"] = { "Officier", "Officer" },
    ["CHANNEL_MDJ"] = { "MdJ de confrérie", "Kin MotD" },
    ["CHANNEL_RDC"] = { "Recherche de com.", "Looking for fellow." },
    ["CHANNEL_CUST1"] = { "Canal perso. 1", "Cust. chan 1" },
    ["CHANNEL_CUST2"] = { "Canal perso. 2", "Cust. chan 2" },
    ["CHANNEL_CUST3"] = { "Canal perso. 3", "Cust. chan 3" },
    ["CHANNEL_CUST4"] = { "Canal perso. 4", "Cust. chan 4" },
    ["CHANNEL_CUST5"] = { "Canal perso. 5", "Cust. chan 5" },
    ["CHANNEL_CUST6"] = { "Canal perso. 6", "Cust. chan 6" },
    ["CHANNEL_CUST7"] = { "Canal perso. 7", "Cust. chan 7" },
    ["CHANNEL_CUST8"] = { "Canal perso. 8", "Cust. chan 8" },
    ["CHANNEL_MI"] = { "MI", "IM" },
    ["CHANNEL_TALK_C"] = { "/parler", "/say" },
    ["CHANNEL_COMM_C"] = { "/f", "/f" },
    ["CHANNEL_CONF_C"] = { "/k", "/k" },
    ["CHANNEL_RAID_C"] = { "/ra", "/ra" },
    ["CHANNEL_WORLD_C"] = { "/monde", "/world" },
    ["CHANNEL_OFF_C"] = { "/off", "/officer" },
    ["CHANNEL_RDC_C"] = { "/rdc", "/lff" },
    ["CHANNEL_MDJ_C"] = { FromUTF8("/confrérie mdj"), "/kinship motd" },
    ["CHANNEL_CUST1_C"] = { "/1", "/1" },
    ["CHANNEL_CUST2_C"] = { "/2", "/2" },
    ["CHANNEL_CUST3_C"] = { "/3", "/3" },
    ["CHANNEL_CUST4_C"] = { "/4", "/4" },
    ["CHANNEL_CUST5_C"] = { "/5", "/5" },
    ["CHANNEL_CUST6_C"] = { "/6", "/6" },
    ["CHANNEL_CUST7_C"] = { "/7", "/7" },
    ["CHANNEL_CUST8_C"] = { "/8", "/8" },
    ["CHANNEL_MI_C"] = { "/dire", "/tell" },
    ["COLOR_T1"] = { "Couleurs unies", "Plained colors" },
    ["COLOR_T2"] = { "Arc-En-Ciel", "Rainbowed" },
    ["COLOR_T3"] = { "Dégradé", "Layered" },
    ["COLOR_T4"] = { "Vagues", "Waves" },
    ["CONFIG_SHOWCLOSMSG"] = { "Afficher la commande à la fermeture", "Print opening command at closing" },
    ["OPEN_CONFIG"] = { "Ouvrir le panneau de configuration", "Open configurations window" },
    ["ADDICO_TOOLTIP"] = { "Ajouter une couleur à la liste", "Add a color to the list" },
};
