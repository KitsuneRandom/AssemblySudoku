# AssemblySudoku

Résolveur de Sudoku écrit en assembleur.

## Présentation
AssemblySudoku est un programme en assembleur capable de résoudre une grille de Sudoku. Il ne prend pas une grille mise en forme, mais **une suite de 81 chiffres** représentant les cases à remplir :
- Les chiffres **1 à 9** remplissent les cases connues.
- Le chiffre **0** représente une case vide.

Le programme lit ces valeurs depuis un fichier texte, **sudoku.txt**, puis calcule et affiche une solution possible.

---

## Préparation
### 1. Fichier d'entrée
Modifiez le fichier `sudoku.txt` contenant exactement **81 chiffres** sans espaces, retours à la ligne ou séparateurs. Exemple :
```
530070000600195000098000060800060003400803001700020006060000280000419005000080079
```

### 2. Configuration du chemin d'accès
Dans le fichier `sudoku.asm`, au niveau de la section `.data`, modifiez la ligne `fichier:` contenant le chemin du fichier pour indiquer **le chemin absolu** vers `sudoku.txt`.

Exemple :
```
fichier: .asciiz "D:\BUT1\sae13\2\sudoku.txt"

```
---

## Exécution
Une fois compilé et exécuté, le programme :
1. Lit les 81 chiffres dans `sudoku.txt`.
2. Résout la grille.
3. Affiche en valeur de retour une grille complète et valide.

---

## Licence
Ce projet est distribué sous licence **MIT**. Voir le fichier `LICENSE` pour plus d'informations.

---

## Auteurs
- TRIPIER Lucie
- DE AZEVEDO MAthis

