# Guide AiiDA

L'objectif de ce document est de mettre en avant différentes fonctionnalités d'AiiDA. Pour chaque commande shell, le lecteur trouvera un équivalent Python. Cela lui permet ainsi d'effectuer son développement dans un conteneur AiiDA uniquement depuis un Jupyter Notebook.

## 1. Commandes de base

- ### Pour vérifier l'état du conteneur

```
(base) aiida@0042165b5f00:~/travail$ verdi status
 ✔ version:     AiiDA v2.5.1
 ✔ config:      /home/aiida/.aiida
 ✔ profile:     default
 ✔ storage:     Storage for 'default' [open] @ postgresql://aiida:***@localhost:5432/aiida_db / DiskObjectStoreRepository: 0c43d8f39c7b47d8999439d0f4a43f62 | /home/aiida/.aiida/repository/default/container
 ✔ rabbitmq:    Connected to RabbitMQ v3.10.18 as amqp://guest:guest@127.0.0.1:5672?heartbeat=600
 ✔ daemon:      Daemon is running with PID 437
```

Par la suite, la partie **(base) aiida@0042165b5f00:~/travail** ne sera plus affichée.

- ### Pour ouvrir un terminal Python avec l'environnement AiiDA préchargé

```
$ verdi shell
```

<img src="Images/Attention.png" width="15" height="15"> **Attention** <img src="Images/Attention.png" width="15" height="15"> : Ce terminal Python possède certaines variables d'environnement et bibliothèques Python pré-importées.

- ### Pour sortir du terminal Python

```python
In [1]: exit
```
<img src="Images/Attention.png" width="15" height="15"> **Attention** <img src="Images/Attention.png" width="15" height="15"> : Si cette commande est exécutée dans le terminal AiiDA (**(base) aiida@0042165b5f00:~/travail$** par exemple), cela provoquera la fermeture et destruction du conteneur.

- ### Pour exécuter un programme Python dans AiiDA

```
$ verdi run programme.py
```

Cette commande permet d'exécuter un programme Python avec le même environnement que celui généré par la commande **"$ verdi shell"**. La commande Python équivalente (permettant de s'abstreindre de l'utilisation du Command Line Interface (CLI) verdi) est la suivante :

```python
from aiida import load_profile
load_profile()
```

<img src="Images/Attention.png" width="15" height="15"> **Attention** <img src="Images/Attention.png" width="15" height="15"> : Cette dernière commande est nécessaire pour l'utilisation d'un Jupyter Notebook. En effet, un Jupyter Notebook ne peut être simplement exécuté via une commande du shell 
```
$ verdi ...
```

- ### Utilisation du daemon

Le daemon est un programme informatique qui s'exécute en arrière-plan. Ici, il permet de gérer l'attribution des différentes ressources de calcul aux processus engagés.




## 2. Gestion des Nœuds AiiDA

Dans AiiDA, l'historique des calculs est stocké sous la forme d'un graphe de provenance. Pour générer ses nœuds, le module AiiDA **orm** est utilisé. (ORM = Object-Relational Mapping)

- ### Gestion des variables

**<ul><ul><li>Dans Python</ul></ul>**

```python
In [1]: from aiida import orm
   ...: noeud = orm.Int(2)
```
Un nœud a été déclaré avec pour type : **Int** et pour valeur : **2**.


Pour vérifier son contenu dans Python :

```py
In [2]: noeud
Out[2]: <Int: uuid: 879a70a6-b412-4bf0-ba9d-1ab461a97a64 (unstored) value: 2>
```

A cet instant, le nœud a beau avoir été déclaré, il n'est pas stocké pour autant.
Il faut ainsi utiliser la commande :

```py
In [4]: noeud.store()
Out[4]: <Int: uuid: 879a70a6-b412-4bf0-ba9d-1ab461a97a64 (pk: 1) value: 2>>
```

Le nœud se voit alors attribuer une clef d'identification (pk) utilisable à la place de son uuid. 

Pour déclarer une variable à partir d'un nœud déja existant :

```py
noeudbis = orm.load(1)
noeudter = orm.load(uuid='879a70a6')
```

NB : Par défaut, c'est la clé pk qui est attendue en argument pour faire référence à un nœud. Seuls les 8 premiers caractères suffisent en général à faire référence à un nœud unique à partir de son uuid. De plus, les \`**-**\` y sont muets. 

**<ul><ul><li>Dans le terminal AiiDA</ul></ul>**

L'état d'un nœud (ici de clef **pk: 1**) peut être affiché à l'aide de la commande :

```
$ verdi node show 1
Property     Value
-----------  ------------------------------------
type         Int
pk           1
uuid         b1307b87-aa75-4684-bde9-2be93632d571
label
description
ctime        2024-05-02 08:26:17.697612+00:00   #date de création
mtime        2024-05-02 08:26:17.710215+00:00   #date de dernière modification
```

La commande **$ verdi node show b1307b87** aurait eu le même effet.

- ### Fonctions de calcul

Dans AiiDA, l'exécution d'une fonction de calcul crée et/ou stocke automatiquement plusieurs nœuds représentant:

<ul>
  <ul>
  <li>La fonction exécutée
  <li>Les variables d'entrée qui n'étaient pas encore stockées
  <li>Les variables de sortie
  </ul>
</ul>

Celles-ci sont générables à l'aide du module AiiDA **engine**.


```py
from aiida import engine

@engine.calcfunction    #Convertit la fonction en une "Fonction de calcul AiiDA"
def fonction(x, y) :
    ...
    return resultat
```

L'appel d'une fonction génère un nœud représentant le processus. 

Pour afficher les processus en cours et/ou terminés :

```
%verdi process list -a  #-a permet d'afficher en plus les calculs terminés
  PK  Created    Process label    ♻    Process State    Process status
----  ---------  ---------------  ---  ---------------  ----------------
   3  2s ago     fonction            ⏹ Finished [0]

Total results: 1
```

Tout comme les variables, le nœud d'un processus peut être examiné :
```
$ verdi node show 6
Property     Value
-----------  ------------------------------------
type         fonction
state        Finished [0]
pk           3
uuid         7888a379-75ec-4405-a6d9-05d06ad600b4
label        multiplier
description
ctime        2024-05-02 09:23:24.021813+00:00
mtime        2024-05-02 09:23:24.163042+00:00

Inputs      PK  Type
--------  ----  ------
x            1  Int
y            2  Int

Outputs      PK  Type
---------  ----  ------
result        4  Int
```

Afin de générer le graphe de provenance :

```py
$ verdi node graph generate --identifier pk 3 graphe_multiplication.pdf
```

Commentaires :
1. Ici, le graphe de provenance est identifié grâce à la clef (**3**) de la fonction de calcul.92a0c
2. **--identifier pk** permet d'identifier les nœuds du graphe à l'aide leur clef et non de leur uuid.
3. Le graphe généré est un pdf par défaut mais l'extension **.pdf** doit apparaître à la fin du nom (optionnel) indiqué.

Pour afficher le statut d'un processus et de ceux dont il dépend directement (dans le cas d'un [flux de travail](#8-création-dun-flux-de-travail--workflow) par exemple) :

```
$ verdi process status 34
MultiplyAddWorkChain<34> Finished [0] [3:result]
    ├── multiply<35> Finished [0]
    └── ArithmeticAddCalculation<37> Finished [0]
```

## 3. Gestion des machines de calcul

- ### Pour établir une nouvelle machine pour effectuer des calculs

```
$ verdi computer setup -L NouvelOrdi -H localhost -T core.local -S core.direct -D 'Cet ordinateur sert de test.' -w `echo $PWD/work` -n
Success: Computer<4> NouvelOrdi created
Report: Note: before the computer can be used, it has to be configured with the command:
Report:   verdi -p default computer configure core.local NouvelOrdi
$ verdi computer configure core.local NouvelOrdi --safe-interval 1 -n
Report: Configuring computer NouvelOrdi for user aiida@localhost.
```

Commentaires :
1. **-L** déclare le nom de cette machine
2. **-H** l'hôte de cette machine (ici il est local)
2. **-T** le PLUGIN de transport
3. **-S** le PLUGIN de planification (=Scheduler)
4. **-D** la description de cette machine
5. **-w \`echo $PWD/work`** crée un sous-dossier (ici nommé **work**) où effectuer les calculs
5. Voici la commande Python équivalente : 
```py
from aiida import orm
computer = orm.Computer(label='NouvelOrdi',hostname='localhost',transport_type='core.local',scheduler_type='core.direct',description='Cet ordinateur sert de test.',workdir='/home/aiida/aiida_run/').store()
computer.configure(safe_interval='1',use_login_shell='1')
```

- ### Pour gérer les différentes machines


**<ul><ul><li> Pour avoir la liste des machines : </ul></ul>**

```
$ verdi computer list
Report: List of configured computers
Report: Use 'verdi computer show COMPUTERLABEL' to display more detailed information
* NouvelOrdi
* localhost
```


**<ul><ul><li> Pour avoir des informations détaillées sur une machine : </ul></ul>**

```
$ verdi computer show NouvelOrdi
---------------------------  ------------------------------------
Label                        NouvelOrdi
PK                           4
UUID                         0ba535b4-f795-40c5-82e8-7f275e0693ca
Description                  Cet ordinateur sert de test.
Hostname                     localhost
Transport type               core.local
Scheduler type               core.direct
Work directory               /home/aiida/travail/work
Shebang                      #!/bin/bash
Mpirun command               mpirun -np {tot_num_mpiprocs}
Default #procs/machine
Default memory (kB)/machine
Prepend text
Append text
---------------------------  ------------------------------------
```
NB : Les clefs **pk** et **uuid** des machines sont stockées dans une base de donnée différente de celle des nœuds. Il peut ainsi exister simultanément une machine et un nœud de **pk=1**.

**<ul><ul><li> Pour afficher la configuration actuelle d'une machine : </ul></ul>**

```
$ verdi computer configure show NouvelOrdi
* use_login_shell  1
* safe_interval    1
```

**<ul><ul><li> Pour supprimer une machine : </ul></ul>**

```
$ verdi computer delete NouvelOrdi
Success: Computer 'NouvelOrdi' deleted.
```

- ### Pour gérer les codes à exécuter

**<ul><ul><li> Pour créer un code : </ul></ul>**

Ici, un code est créé à partir du plugin **core.arithmetic.add** socké dans **core.code.installed**, l'exécutable est **/bin/bash**.
```
$ verdi code create core.code.installed -L MonCode -Y NouvelOrdi -X /bin/bash -P 'core.arithmetic.add' -D 'Ceci est une description.' -n
```

Commentaires :
1. **-L** le nom
2. **-Y** la machine permettant l'exécution
2. **-X** l'endroit où se trouve le programme à exécuter
3. **-P** le point d'entrée du PLUGIN de calcul
4. **-D** la description du code
5. Voici la commande Python équivalente pour `pw.x` : 
```py
from aiida import orm
orm.InstalledCode(label='MonCode', computer = load_computer('NouvelOrdi'), filepath_executable='/usr/local/bin/pw.x', default_calc_job_plugin='quantumespresso.pw', description='Ceci est une description.').store()
```

**<ul><ul><li> Pour avoir la liste des codes : </ul></ul>**

```
$ verdi code list
Full label            Pk  Entry point
------------------  ----  -------------------
MonCode@NouvelOrdi    17  core.code.installed
```


**<ul><ul><li> Pour avoir des informations détaillées sur un code : </ul></ul>**

```
$ verdi code show MonCode
-----------------------  ------------------------------------
PK                       17
UUID                     d31e2b27-6278-4085-bc16-5f5d12326b7e
Type                     core.code.installed
Computer                 NouvelOrdi (localhost), pk: 5
Filepath executable      /bin/bash
Label                    MonCode
Description              Ceci est une description.
Default calc job plugin  core.arithmetic.add
Use double quotes        False
With mpi
Prepend text
Append text
-----------------------  ------------------------------------
```

**<ul><ul><li> Pour supprimer un code : </ul></ul>**

```
$ verdi code delete -f MonCode
Report: 1 Node(s) marked for deletion
Report: Starting node deletion...
Report: Deletion of nodes completed.
Success: Finished deletion.
```
L'option **-f** permet de forcer la suppression (et donc de ne pas demander de confirmation).

- ### Pour exécuter un code à l'aide d'un script Python

Pour exécuter un code déjà installer, il faut faire appel à un patron de conception (= monteur = builder). Celui-ci permet, à partir du code, de créer un environnement fonctionnel avec des variables et/ou options exploitables par la machine.

**<ul><ul><li> Pour attribuer le code à une variable : </ul></ul>**

```py
Code = orm.load_code(label='MonCode')
```

**<ul><ul><li> Pour créer le patron de conception : </ul></ul>**

```py
In [665]: MonMontage = Code.get_builder()

In [666]: MonMontage
Out[666]:
Process class: ArithmeticAddCalculation
Inputs:
code: ''
metadata:
  options:
    stash: {}
monitors: {}
```

**<ul><ul><li> Pour ajouter une variable au montage : </ul></ul>**

```py
MonMontage.x = orm.Int(3)
```


**<ul><ul><li> Pour exécuter le montage : </ul></ul>**

```py
engine.run(MonMontage)      #par la machine
engine.submit(MonMontage)   #par le daemon
```

Tout comme pour les fonctions de calcul, un processus est lancé et génère ainsi un nœud permettant de visualiser l'opération réalisé à l'aide des commandes **\$ verdi node show** ou **\$ verdi node graph generate**.

## 4. Création d'un flux de travail (= "Workflow")

Un flux de travail permet d'exécuter automatiquement plusieurs codes et/ou plugins consécutivement. Ces flux sont montés à l'aide d'un patron de conception comme pour les codes mutatis mutandis et sont créés à partir d'un code ou d'un plugin.

- ### Exemple de création d'un flux de travail à partir d'un plugin

```py
from aiida import orm
builder = MultiplyAddWorkChain.get_builder()
builder.code = orm.load_code(label='add')
builder.x = orm.Int(2)
builder.y = orm.Int(3)
builder.z = orm.Int(5)
builder
```

Il est possible d'inspecter le plugin initial pour savoir les arguments attendus, dans notre cas :

```
$ verdi plugin list aiida.workflows core.arithmetic.multiply_add
Description:

    WorkChain to multiply two numbers and add a third, for testing and demonstration purposes.

Inputs:
    code  AbstractCode
       x  Int
       y  Int
       z  Int
metadata

Required inputs are displayed in bold red.

Outputs:
result  Int

Required outputs are displayed in bold red.

Exit codes:

  0  The process finished successfully.
  1  The process has failed with an unspecified error.
  2  The process failed with legacy failure mode.
 10  The process returned an invalid output.
 11  The process did not register a required output.
400  The result is a negative number.

Exit codes that invalidate the cache are marked in bold red.
```

Dans ce cas, puisque le patron de conception possède bien les 4 inputs aux bons formats, il peut être exécuté.