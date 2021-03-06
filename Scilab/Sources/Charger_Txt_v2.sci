clear;
clc;

//* ***************************************************************************
//* Tracer la Papp et Base
//*****************************************************************************
function tracer(TabPapp, TabBase)
subplot(2,1,1)
plot(TabPapp)
subplot(2,1,2)
plot(TabBase,'g')
endfunction

//* ***************************************************************************
//* Décomposer la ligne en %s %s %s %s
//*****************************************************************************
function decomposerSSSS(donneeStr)
    temp = msscanf(donneeStr,'%s %s %s %s');
    tailleTemp = size(temp);
    tailleTemp = tailleTemp(2);
    
    // Heure Papp Base [Inval]
    if tailleTemp == 4 then
        tabStr = temp(1);
        tabDbl = [evstr(temp(2)) evstr(temp(3)) evstr(temp(4))];

    // Heure Papp
    elseif tailleTemp == 2 then
        tabStr = temp(1);
        tabDbl = [evstr(temp(2)) 0 0];
    
    // Heure Papp Inval
    else
        // Pas Base mais Inval = 1
        if evstr(temp(3)) == 1 then
            tabStr = temp(1);
            tabDbl = [evstr(temp(2)) 0 1];
        else
            tabStr = temp(1);
            tabDbl = [evstr(temp(2)) evstr(temp(3)) 0];
        end
    end
    
    [Gbl_tabStr,Gbl_tabDbl] = resume(tabStr,tabDbl);
endfunction

//* ***************************************************************************
//* Décomposer la ligne avec des largeures fixes
//****************************************************************************
function decomposerPart(donneeStr)
    tabDbl = zeros(4,1);

    tabStr = part(donneeStr,[1:8]); // Heure
    tabDbl(1) = evstr(part(donneeStr,[12:16])); // Papp
    tabDbl(2) = evstr(part(donneeStr,[20:29])); // Base / HC
    try
        tabDbl(3) = evstr(part(donneeStr,[33:42])); // Invalide / HP
        try
            tabDbl(4) = evstr(part(donneeStr,[46])); // - / Invalide
        catch
            tabDbl(4) = 0;
        end
    catch
        tabDbl(3) = 0;
        tabDbl(4) = 0;
    end
    
    [Gbl_tabStr,Gbl_tabDbl] = resume(tabStr,tabDbl);
endfunction

//* ***************************************************************************
//* Programme extraction du fichier texte
//*****************************************************************************
clc;

disp('Début du programme');

fnctPath = pwd();
projectPath = strncpy(pwd(),length(pwd())-length("\Scilab"));
dataPath2Read = projectPath + "\Code\Compteur_Linky\Releves";
dataPath2Save = dataPath2Read + "\Variables";
dataPath = dataPath2Read;
 
cheminFichier = uigetfile(["*.txt"],dataPath, ...
    "Choisir le fichier à ouvrir", %f);
fichier = mopen(cheminFichier,'r'); 
donnee = mgetl(cheminFichier);  
mclose(cheminFichier);

disp('Début du traitement');

offset = 5;
nbrLignes = size(donnee)-1;
nbrLignes = nbrLignes(1,1)-offset -1;

//Initialisation des tableaux
TabHeure(1:nbrLignes) = [""];
TabPapp = zeros(nbrLignes);
TabBase = zeros(nbrLignes);
TabInval = zeros(nbrLignes);

// Extraction des lignes vers les tableau TabHeure, TabPapp, TabBase et TabInval
tic();

// Remplissage de la première ligne
ligne = 1;
TabBase(ligne) = 0;

// Fonction decomposer SSSS
//decomposerSSSS(donnee(offset+ligne));
decomposerPart(donnee(offset+ligne));
TabHeure(ligne) = Gbl_tabStr;
TabPapp(ligne) = Gbl_tabDbl(1);
IndexBase = Gbl_tabDbl(2);
TabInval(ligne) = Gbl_tabDbl(3);

// Remplissage des autres lignes
for ligne = 2:(nbrLignes)
//        decomposerSSSS(donnee(offset+ligne));
        decomposerPart(donnee(offset+ligne));
        TabHeure(ligne) = Gbl_tabStr;
        TabPapp(ligne) = Gbl_tabDbl(1);
        if Gbl_tabDbl(2) == 0 then
            TabBase(ligne) = TabBase(ligne-1);
        else
            TabBase(ligne) = Gbl_tabDbl(2) - IndexBase;
            TabInval(ligne) = Gbl_tabDbl(3);
        end
end

disp(toc());
disp('Fin de traitement');
disp(cheminFichier);

// Sur PC Seb
// Fichier Releve_2013-Essai.txt avec decomposerSSSS, 33.387s
// Fichier Releve_2013-Essai.txt avec decomposerSDDD, arreté après 5 minutes
// Fichier Releve_2013-Essai.txt avec decomposerPart, 39.071s


tracer(TabPapp, TabBase);
