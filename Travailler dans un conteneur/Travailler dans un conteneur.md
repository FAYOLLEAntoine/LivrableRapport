# Travailler dans un conteneur

Voici différentes commandes et informations afin de mettre en avant différentes fonctionnalités de Podman pour travailler dans un conteneur.

## 1. Images

Les images sont construites à partir d'un "dockerfile". Une fois une image construite, l'utilisateur peut construire et administrer de multiples conteneurs basée sur ette unique image.

- ### Pour télécharger une image
```bash
$ podman pull aiidateam/aiida-core-with-services:latest
```

- ### Pour construire une image à partir d'un dockerfile local
```
$ podman build --format=docker -t docker_image .
```

- ### Pour vérifier la liste des images installées et prêtes à l'emploi :
```
$ podman images
REPOSITORY                                    TAG         IMAGE ID      CREATED       SIZE
quay.io/podman/hello                          latest      9e0dd3d2c11c  3 days ago    752 kB
docker.io/library/ubuntu                      latest      7af9ba4f0a47  6 days ago    80.4 MB
docker.io/aiidateam/aiida-core-with-services  latest      1076bc0b061f  2 months ago  1.71 GB
```

- ### Pour supprimer une image installée (cette image ne doit pas posséder de conteneur):
```
$ podman rmi hello:latest 
Untagged: quay.io/podman/hello:latest
Deleted: 9e0dd3d2c11c0d76d3662d24dff6e797adeccedc0f963e90f4bf2a8908d4f708
```

## 2. Volumes

#### Note Liminaire :
Podman possède une commande pour créer des volumes dans un espace qu'il gère directement. Pour autant, n'importe quel dossier peut être traité comme tel. Pour des questions de droits d'accès, nous privilégierons les dossiers. Les commandes suivantes ne sont donc présentées qu'à titre informatif et ne seront pas exploitées pour ce projet.

- ### Pour créer un volume

```
$ podman volume create myvolume
```

- ### Pour vérifier la liste des volumes déjà existants :

```
$ podman volume ls
DRIVER      VOLUME NAME
local       myvolume
```

Ils sont localisés dans **/local/.user/volumes** .


- ### Pour supprimer un volume :
```
$ podman volume rm myvolume
myvolume
```

- ### Gestion des droits sur le volume


<img src="Images/Attention.png" width="15" height="15"> **Attention** <img src="Images/Attention.png" width="15" height="15"> : Par défaut, l'utilisateur dans le conteneur n'a pas les mêmes droits que l'utilisateur à l'origine du conteneur. Pour cela, lors de l'exécution du conteneur, une commande (**--userns:keep-id**) leur permet de coincider.


## 3. Conteneurs

- ### Pour créer et lancer un conteneur
```
$ podman run -it --rm -v ./travail:/home/aiida/travail:z --userns=keep-id:uid=1000,gid=100 --device nvidia.com/gpu=all --security-opt=label=disable --tz=Europe/Paris --name aiida-demo localhost/aiida-qe-w90-x:latest bash
```

Commentaires :
1. **-it** permet d'exécuter le conteneur par la suite dans le terminal actuel
2. **-v ./travail:/home/aiida/travail:z** permet de fournir au conteneur l'accès au dossier déjà existant **travail** (supposé accessible directement depuis le terminal) dans un répertoire **travail** créé pour cela
4. **--rm** permet de supprimer automatiquement le conteneur après l'avoir quitté
5. **--userns:keep-id=uid=1000,gid=100** permet de faire coincider l'utilisateur dans le conteneur avec son exécuteur.
6. **--device nvidia.com/gpu=all --security-opt=label=disable** donne au conteneur l'accès au GPU
7. **--tz=Europe/Paris** permet d'avoir le bon fuseau horaire dans le conteneur
8. **--name aiida-demo** pour nommer le conteneur
9. **localhost/aiida-qe-w90-x:latest** l'image à partir de laquelle construire le conteneur
10. **bash** la commande à effectuer au lancement du conteneur, ici **bash** ouvre un terminal dans le conteneur 


- ### Pour vérifier la liste de tous les conteneurs et leurs états :
```
$ podman ps -a
CONTAINER ID  IMAGE                                                COMMAND               CREATED         STATUS                    PORTS       NAMES
7fb835bd1da5  quay.io/podman/hello:latest                          /usr/local/bin/po...  5 minutes ago   Exited (0) 2 minutes ago              hello
f8b3bec82190  docker.io/aiidateam/aiida-core-with-services:latest  bash                  4 minutes ago   Up 4 minutes                          aiida-demo
4a91a85b40a4  docker.io/library/ubuntu:latest                      bash                  1 second ago    Up 1 second                           ubuntu-test
```

- ### Pour vérifier la liste de tous les conteneurs actifs :
```
$ podman ps
CONTAINER ID  IMAGE                                                COMMAND     CREATED         STATUS         PORTS       NAMES
f8b3bec82190  docker.io/aiidateam/aiida-core-with-services:latest  bash        4 minutes ago   Up 4 minutes               aiida-demo
4a91a85b40a4  docker.io/library/ubuntu:latest                      bash        1 second ago    Up 1 second                ubuntu-test
```


## 4. Travailler dans le conteneur depuis VSCode

- ### Pour pouvoir ouvrir le conteneur

Installer l'extension **Dev Containers** <img src="Images/DevContainers.png" width="25" height="25"> .


<img src="Images/Attention.png" width="15" height="15"> **Attention** <img src="Images/Attention.png" width="15" height="15"> : Pour maintenir **up** le conteneur de AiiDA, le terminal dans lequel il a été ouvert ne doit pas être clos.

- ### Pour ouvrir le conteneur depuis VSCode :

`Ctrl + Alt + o` -> `Attacher au conteneur en cours d'exécution...`->`aiida-demo`

Cette étape peut prendre quelques minutes.  

- ### Pour avoir accès aux extensions de VSCode
Certaines extensions doivent être réinstallées dans le conteneur :   

`Ctrl + Maj + X` -> `Installer dans ConteneurDocker.io/aiida...`

- ### Pour ouvrir le volume

`Ctrl + o` -> `/home/aiida/travail/`

<img src="Images/Attention.png" width="15" height="15"> **Attention** <img src="Images/Attention.png" width="15" height="15"> : Tout le contenu produit hors du volume au sein du conteneur sera **définitivement** perdu à l'arrêt de ce dernier.

## 5. Utiliser un Jupyter Notebook dans AiiDA via VSCode

Voici la liste des conditions à réunir :

- #### Avoir un conteneur AiiDA ouvert et rattaché à une fenêtre VSCode

Cela permet d'exposer le port du serveur Jupyter (par défaut le 8888) auprès de 'localhost'.

 S'il n'apparaît pas automatiquement : Aller dans l'onglet' `Port` (à côté de `Terminal`) de la fenêtre attachée au coneneur : `Ajouter un port`-> `8888`

- #### Avoir installé Jupyter Notebook dans le conteneur:
(Certaines images ont déjà jupyter d'installé au préalable, dans ce cas cela n'est pas nécessaire.)
```sh
$ jupyter --version
$ conda install jupyter
```

- #### Dans un terminal du conteneur, créer un serveur Jupyter Notebook :

```sh
$ jupyter notebook
```
Un lien est alors généré, il contient une adresse (avec le port 8888 et un token permettant de se connecter au serveur).

Exemple :

```
    To access the server, open this file in a browser:
        file:///home/aiida/.local/share/jupyter/runtime/jpserver-50241-open.html
    Or copy and paste one of these URLs:
        http://localhost:8888/tree?token=<numero_du_token>
        http://127.0.0.1:8888/tree?token=<numero_du_token>
```

- #### Avoir ouvert une fenêtre VSCode hors conteneur avec l'extension Jupyter <img src="Images/jupyter.png" width="50" height="50"> activée

Depuis cette fenêtre, il est alors possible d'ouvrir des fichiers au format **.ipynb** (IPython Notebook).

- #### Activer le serveur Jupyter dans VSCode

Depuis la fenêtre hors conteneur de VSCode, dans un document .ipynb :

<ul>
    <ul>
    <li><img src="Images/Select_Kernel.png" width="160">
    <li><code>Serveur Jupyter Existant...</code>
    <li><code>http://127.0.0.1:8888/tree?token=&lt;numero_du_token&gt;</code>
    <li><code>&lt;Nom_d'affichage_du_serveur_dans_VSCode&gt; </code>
    <li><code>Python 3 (ipykernel)</code>
    </ul>
</ul>

- #### Alertes/Warnings Pylance

En raison de l'analyse du script Python hors du conteneur, les commandes propres à AiiDA ne seront pas reconnues dans l'interface graphique malgré leur bon fonctionnement. Afin d'éviter ces alertes superflues, deux solutions sont proposées :

- Ajouter au tout début de chaque section de code python des fichiers **.ipynb**, l'instruction :
```
# type: ignore
```
- Ajouter au fichier de paramètres VSCode **settings.json** (accessible via l'onglet Paramètre -> python.analysis.diagnosticSeverityOverrides -> Modifier dans settings.json) : 
```
"python.analysis.diagnosticSeverityOverrides": {
    "reportMissingImports": "none"
}
```