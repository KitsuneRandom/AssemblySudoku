# ===== Section donnees =====  
.data

    grille: .space 81			# Buffer pour stocker le tableau
    tableau: .space 10 			# Buffer de 10 octets utilisé pour check_n_column et check_n_row
    fichier: .asciiz "D:\BUT1\sae13\2\sudoku.txt"	# Nom et chemin d'acces du fichier du sudoku
    buffer: .space 1			# Buffer (sorte d'allocation memoire qui sera utilisée pour stocker temporairement un caract�re)
    #grille: .asciiz "415038972362479185789215364926341758138756429574982631257164893843597216691823547"

 

# ===== Section code =====  
.text
# ----- Main ----- 

main:
    jal parseValues
    jal zeroToSpace
    jal transformAsciiValues
    jal displayGrille
    jal addNewLine
    jal displaySudoku
    jal addNewLine
    jal solve_sudoku
    j exit

# ----- Fonctions ----- 

# ----- Fonction addNewLine -----  
# objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0
addNewLine:
    li      $v0, 11
    li      $a0, 10
    syscall
    jr $ra



# ----- Fonction displayGrille -----   
# Affiche la grille.
# Registres utilises : $v0, $a0, $t[0-2]
displayGrille:  
    la      $t0, grille
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    li      $t1, 0
    boucle_displayGrille:
        bge     $t1, 81, end_displayGrille     # Si $t1 est plus grand ou egal a 81 alors branchement a end_displayGrille
            add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            lb      $a0, ($t2)              # load byte at $t2(adress) in $a0
            beq $a0, 32, affiche_char	    # si a0 est un espace, l'afficher en tant que caractère
            li      $v0, 1                  # code pour l'affichage d'un entier
            j end_affiche_char
            affiche_char:
                li $v0, 11		    # code pour l'affichage d'un caractère ascii
            end_affiche_char:
            syscall
            add     $t1, $t1, 1             # $t1 += 1;
        j boucle_displayGrille
    end_displayGrille:
        lw      $ra, 0($sp)                 # On recharge la reference 
        add     $sp, $sp, 4                 # du dernier jump
    jr $ra


# ----- Fonction transformAsciiValues -----   
# Objectif : transforme la grille de ascii a integer
# Registres utilises : $t[0-3]
transformAsciiValues:  
    add     $sp, $sp, -4
    sw      $ra, 0($sp)
    la      $t3, grille
    li      $t0, 0
    boucle_transformAsciiValues:
        bge     $t0, 81, end_transformAsciiValues
            add     $t1, $t3, $t0
            lb      $t2, ($t1)
            sub     $t2, $t2, 48
            sb      $t2, ($t1)
            add     $t0, $t0, 1
        j boucle_transformAsciiValues
    end_transformAsciiValues:
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra


# ----- Fonction getModulo ----- 
# Objectif : Fait le modulo (a mod b)
#   $a0 represente le nombre a (doit etre positif)
#   $a1 represente le nombre b (doit etre positif)
# Resultat dans : $v0
# Registres utilises : $a0
getModulo: 
    sub     $sp, $sp, 4
    sw      $ra, 0($sp)
    boucle_getModulo:
        blt     $a0, $a1, end_getModulo
            sub     $a0, $a0, $a1
        j boucle_getModulo
    end_getModulo:
    move    $v0, $a0
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra


# Nom et prenom binome 1 : DE AZEVEDO Mathis                     
# Nom et prenom binome 2 : TRIPIER Lucie                     
#                                               #
# Fonction check_n_column                       #
# Vérifie la validité de la n-ième colonne
#            numéro de la ligne stocké dans $s1
# Registres utilisés : $t[0-9], $s0
check_n_column:
    beq $s0, 1, end_check_n_column	#si une des colonnes précédentes est fausse, pas la peine de tout re tester
    la $t0, grille			# adresse du début de la grille
    la $t1, tableau			# adresse du début du tableau
    li $t2, 0				# numéro de ligne
    li $t8, 1				# indice pour la boucle 2
    boucle1_check_n_column:			#boucle qui trouve les nombres a une colonne donnée et incrémente dans le tableau le nombre de fois où on trouve chaque nombre
        beq $t2, 9, boucle2_check_n_column	# si dernière ligne dépassée, 2e boucle
        move $t4, $t0				# adresse de la grille dans $t4
        mul $t3, $t2, 9				# indice du début de la ligne dans la grille
        add $t4, $t4, $t3			# ajout de l'indice à l'adresse
        add $t4, $t4, $s1			# ajout du numéro de colonne qui nous intéresse
        lb $t5, ($t4)				# on récupère la valeur à l'adresse calculée
        add $t6, $t1, $t5			# adresse du tableau de décompte à l'indice du numéro (ex: si grille[3] = 5, on récupère l'adresse de tableau[5]
        lb $t7, ($t6)				# on récupère la valeur à cette adresse
        addi $t7, $t7, 1			# on l'incrémente de 1
        sb $t7, ($t6)				# on la stock au même endroit
        addi $t2, $t2, 1			# ligne suivante
        j boucle1_check_n_column
    boucle2_check_n_column:			#vérifie si chaque nombre n'est présent qu'une fois maximum
        beq $t8, 10, end_check_n_column		# de 1 à 9, à 9 on passe à la fin sans passer par la modification du booléen
        move $t9, $t1				# on récupère l'adresse du tableau
        add $t9, $t9, $t8			# on ajoute l'indice
        lb $t9, ($t9)				# on récupère la valeur à l'indice calculé
        bge $t9, 2, false_check_n_column	# si une valeur apparaît plus de 1 fois, le booléen passe à 1
        addi $t8, $t8, 1			# incrémentation de l'indice
        j boucle2_check_n_column
false_check_n_column:
    li $s0, 1					# le booléen passe à 1
end_check_n_column:
    jr $ra
    
# Fonction check_n_rows
# Vérifie la validité de la n-ième ligne
#            numéro de la ligne stocké dans $s1
# Registres utilisés : $t[0-9], $s0  
#renvoie le résultat dans $s0

check_n_row:					#check UNE ligne  (RECEVOIR LE NUM DE LA LIGNE DANS $S1)
	beq $s0, 1, end_check_n_row		#si une des lignes précédentes est fausse, pas la peine de tout re tester
	la $t0, grille				# adresse du début de la grille
	la $t1, tableau				# adresse du début du tableau
	mul $t2, $s1, 9				# indice du 1er nombre dans la grille, par forcément correct pour le moment
	li $t3, 0				# indice qui permet de véfier le nombre de fois que incremente dans le tab a été fait
	li $t8, 1				# indice dans le tableau
	move $t9, $s1				#permet de ne pas modifier $s1
	boucle_incremente_dans_le_tab:
		beq $t3, 9, verif_qu_y_a_pas_de_doublon_ligne	# si on est a la fin de la ligne on s'arrête et on vérifie le tableau
	        move $t4, $t0				# adresse de la grille dans $t4
	        add $t4, $t4, $t2			# ajout de l'indice à l'adresse
	        lb $t5, ($t4)				# on récupère la valeur à l'adresse calculée
	        add $t6, $t1, $t5			# adresse du tableau de décompte à l'indice du numéro (ex: si grille[3] = 5, on récupère l'adresse de tableau[5]
	        lb $t7, ($t6)				# on récupère la valeur à cette adresse
	        addi $t7, $t7, 1			# on l'incrémente de 1
	        sb $t7, ($t6)				# on la stock au même endroit
	        addi $t2, $t2, 1			# ligne suivante
	        addi $t3, $t3, 1			#on incrémente pour passer a la case suivante
		j boucle_incremente_dans_le_tab
	verif_qu_y_a_pas_de_doublon_ligne:		#vérifie si chaque nombre n'est présent qu'une fois maximum
        	beq $t8, 10, end_check_n_row		# de 1 à 9, à 9 on passe à la fin sans passer par la modification du booléen
		move $t9, $t1				# on récupère l'adresse du tableau
        	add $t9, $t9, $t8			# on ajoute l'indice
        	lb $t9, ($t9)				# on récupère la valeur à l'indice calculé
        	bge $t9, 2, end_y_a_un_doublon_ligne	# si une valeur apparaît plus de 1 fois, le bolléen passe à 1
        	addi $t8, $t8, 1		# incrémentation de l'indice	
        	j verif_qu_y_a_pas_de_doublon_ligne		
end_y_a_un_doublon_ligne:
	li $s0, 1			#la ligne est fausse
end_check_n_row:
   	jr $ra
# Fonction check_n_square
# Vérifie la validité du n-ième carré
#            numéro du carré stocké dans $s1
# Registres utilisés : $t[0-9], $s0, $s[6-7]
#renvoie le résultat dans $s0
check_n_square:					#check UN carré  (RECEVOIR LE NUM DU CARRÉ DANS $S1)
	move $a2, $ra
	beq $s0, 1, end_check_n_square		#si un des carrés précédents est faux, pas la peine de tout re tester
	la $t0, grille				# adresse du début de la grille
	la $t1, tableau				# adresse du début du tableau
	li $t2, 0 				# indice du 1er nombre dans la grille, par forcément correct pour le moment
	li $t3, 0				# indice qui permet de véfier le nombre de fois que incremente dans le tab a été fait
	li $t8, 1				# indice dans le tableau
	move $t9, $s1				#permet de ne pas modifier $s1
	boucle_trouver_le_1er_nb_du_carre:
		beq $t9, 0, init_boucle		#le numéro de la ligne entrée en paramètres tombe a 0 (puisqu'on le décrémente)
		move $a0, $t2			#met l'indice%27 pour savoir si il faut sauter une ligne ou non
		li $a1, 27			
		jal getModulo
		addi $t2, $t2, 3		#on va au prochain carré
		addi $t9, $t9, -1		#on décrémente de 1 le nombre de carrés
		beq $v0, 6, ajoute18		#si on est a l'indice 6 ou 33 du tableau, il faut sauter 18 cases de plus pour atteindre le carré suivant
		j boucle_trouver_le_1er_nb_du_carre
		ajoute18:
		addi $t2, $t2, 18		#on saute 2 lignes
		j boucle_trouver_le_1er_nb_du_carre
	init_boucle:
		move $s7, $t2				#permet de ne pas modifier $t2 qui est l'indice de départ du carré
	boucle_incremente_dans_le_tableau_carre:
		beq $t3, 9, verif_qu_y_a_pas_de_doublon_carre	# si dernière ligne dépassée, 2e boucle
        	move $t4, $t0				# adresse de la grille dans $t4
        	add $t4, $t4, $s7			# ajout de l'indice à l'adresse
        	lb $t5, ($t4)				# on récupère la valeur à l'adresse calculée
        	add $t6, $t1, $t5			# adresse du tableau de décompte à l'indice du numéro (ex: si grille[3] = 5, on récupère l'adresse de tableau[5]
        	lb $t7, ($t6)				# on récupère la valeur à cette adresse
        	addi $t7, $t7, 1			# on l'incrémente de 1
        	sb $t7, ($t6)				# on la stock au même endroit
        	move $a0, $t2				#utilise une formule mathématique pour savoir si on a atteint le bord du carré
		li $a1, 9				#FORMULE UTILISÉE: si (indice_du_1er_nb_du_carré % 9) - (indice_où_on_est % 9) = -2
		jal getModulo					#ajouter 6 a l'indice_où_on_est
		move $s6, $v0				#ajouter 1 a l'indice_où_on_est
		move $a0, $s7			
		jal getModulo
		sub $s6, $s6, $v0			
        	addi $s7, $s7, 1			
        	addi $t3, $t3, 1			#on incrémente l'indice de la boucle
        	beq $s6, -2, ajoute6			#si on est au bout du carré on va a la ligne d'après
       		j boucle_incremente_dans_le_tableau_carre
        	ajoute6:
        	addi $s7, $s7, 6			#pour passer a la ligne d'après on fait +7 (6 et 1, fait en 2 temps)
		j boucle_incremente_dans_le_tableau_carre	
	verif_qu_y_a_pas_de_doublon_carre:	#vérifie si chaque nombre n'est présent qu'une fois maximum
        beq $t8, 10, end_check_n_square		# de 1 à 9, à 9 on passe à la fin sans passer par la modification du booléen
	move $t9, $t1				# on récupère l'adresse du tableau
        add $t9, $t9, $t8			# on ajoute l'indice
        lb $t9, ($t9)				# on récupère la valeur à l'indice calculé
        beq $t9, 2, end_y_a_un_doublon_carre	# si une valeur apparaît plus de 1 fois, le bolléen passe à 1
        addi $t8, $t8, 1		# incrémentation de l'indice
        j verif_qu_y_a_pas_de_doublon_carre
        
end_y_a_un_doublon_carre:
	li $s0, 1			#le carré est faux
end_check_n_square:
	move $ra, $a2
   	jr $ra
#                                               #
# Fonction check_columns                        #
# vérifie la validité de toutes les colonnes.
# registres utilisés : $s[0-4]
check_columns:
    li $s1, 0					# numéro de la ligne à vérifier
    li $s0, 0					# booléen qui passe à 1 si une colonne n'est pas valide
    boucle_check_columns:
        beq $s1, 9, end_check_columns		# chaque ligne de 0 à 8
        move $s2, $ra				# sauvegarde de l'adresse de retour
        jal check_n_column			# vérification de la colonne $s1
        jal reset_tableau			# remise à 0 de chaque élément du tableau
        move $ra, $s2				# réatribution de la valeur de retour
        beq $s0, 1, end_check_columns		# si $s0 = 1, on sort tt de suite
        addi $s1, $s1, 1			# colonne suivante
        j boucle_check_columns
end_check_columns:
    jr $ra
    
reset_tableau:
    li $s3, 1					# indice du tableau
    boucle_reset_tableau:
        beq $s3, 10, end_reset_tableau		# boucle de 1 à 9
        la $s4, tableau				# adresse du tableau dans $s4
        add $s4, $s4, $s3			# on ajoute l'indice à l'adresse
        sb $zero, ($s4)				# on met l'élément à cette adresse à 0
        addi $s3, $s3, 1			# indice suivant
        j boucle_reset_tableau
end_reset_tableau:
    jr $ra

# Fonction check_rows                        
# vérifie la validité de toutes les lignes.
# registres utilisés : $s[0-4]
#renvoie le résultat dans $s0
check_rows:
    li $s1, 0					# numéro de la ligne à vérifier
    li $s0, 0					# booléen qui passe à 1 si une ligne n'est pas valide
    boucle_check_rows:
        beq $s1, 9, end_check_rows		# chaque ligne de 0 à 8
        move $s2, $ra				# sauvegarde de l'adresse de retour
        jal check_n_row			# vérification de la colonne $s1
        jal reset_tableau			# remise à 0 de chaque élément du tableau
        move $ra, $s2				# réatribution de la valeur de retour
        beq $s0, 1, end_check_rows		# si $s0 = 1, on sort tt de suite
        addi $s1, $s1, 1			# colonne suivante
        j boucle_check_rows
end_check_rows:
    jr $ra
# Fonction check_squares
# vérifie la validité de tous les carrés.
# registres utilisés : $s[0-4]
#renvoie le résultat dans $s0                      
check_squares:
    li $s1, 0					# numéro de la ligne à vérifier
    li $s0, 0					# booléen qui passe à 1 si une ligne n'est pas valide
    boucle_check_squares:
        beq $s1, 9, end_check_squares		# chaque ligne de 0 à 8
        move $s2, $ra				# sauvegarde de l'adresse de retour
        jal check_n_square			# vérification de la colonne $s1
        jal reset_tableau			# remise à 0 de chaque élément du tableau
        move $ra, $s2				# réatribution de la valeur de retour
        beq $s0, 1, end_check_squares		# si $s0 = 1, on sort tt de suite
        addi $s1, $s1, 1			# colonne suivante
        j boucle_check_squares
end_check_squares:
    jr $ra
    
# Fonction check_sudoku
# vérifie la validité de tout le sudoku
# registres utilisés : $s0
#renvoie le résultat dans $s0  

  

check_sudoku:
    addi $sp, $sp, -4 		# Réserve de l'espace sur la pile
    sw $ra, 0($sp)		# Sauvegarde de $ra sur la pile

    jal check_columns		# Vérification des colonnes
    beq $s0, 1, fin		# Si $s0 == 1, le sudoku est invalide

    jal check_rows		# Vérification des lignes
    beq $s0, 1, fin		# Si $s0 == 1, le sudoku est invalide

    jal check_squares		# Vérification des carrés
    beq $s0, 1, fin		# Si $s0 == 1, le sudoku est invalide
fin:
    lw $ra, 0($sp)           # Restaure l'adresse de retour
    addi $sp, $sp, 4         # Libère l'espace sur la pile

    jr $ra                   # Retour à l'appelant

# Fonction solve_sudoku
#fonction récursive qui s’appelle tant que le carré n’est pas fini. 
#Utilise check_sodoku pour vérifier qu’un carré est correct (même si il n’est pas complet), et utilise solve_sudoku pour savoir si le carré final est correct. 
#"sortie" : $s5, mis a 1 si une grille est correcte et complète. Si il est mis a 2 c’est que la grille complète n’est pas valide.
#registres utilisés: $t [0-5], $s5 et $s0 lors de l'appel de check_sudoku
#BONUS : A été amélioré pour faire une vérifier si un nombre peut être mis a un emplacement, 
#évite de faire des appels récursifs inutiles si ce n’est pas le cas. La résolution prend énormément moins de temps avec cette méthode
solve_sudoku:
    addi $sp, $sp, -4        # Réserve de l'espace sur la pile
    sw $ra, 0($sp)           # Sauvegarde de $ra sur la pile
    la $t0, grille				# charge l'adresse de la grille dans $t0
    li $t1, 0				# indice de la boucle parcours de la grille

    parcours_de_la_grille:
        beq $t1, 81, parcours_fini		# boucle for de 0 à 81
        add $t2, $t0, $t1			# adresse de l'élément à l'indice $t1 de la grille dans $t2
        lb $t3, ($t2)				# chargement de la valeur de l'élément à l'adresse $t2 dans $t3
        li $t4, 1				#indice de la boucle verif grille
        beq $t3, 32, verif_grille		# si c'est = a 32 (un espace vaut 32, qui correspond a un 0)
        addi $t1, $t1, 1			#incrémente la valeur
        j parcours_de_la_grille
    verif_grille:				#vérifie si la grille est correcte
    	beq $t4, 10, y_a_pas_de_solutions	#si les chiffres de 1 a 9 ne correspondent pas, la grille est fause
  	sb $t4, ($t2)                    	# Met le chiffre $t4 à la position $t2 dans la grille
  	addi $sp, $sp, -4        # Réserve de l'espace sur la pile
	sw $t1, 0($sp)           # Sauvegarde de $ra sur la pile
	addi $sp, $sp, -4        # Réserve de l'espace sur la pile
	sw $t2, 0($sp)           # Sauvegarde de $ra sur la pile
	addi $sp, $sp, -4        # Réserve de l'espace sur la pile
    	sw $t3, 0($sp)           # Sauvegarde de $ra sur la pile
    	addi $sp, $sp, -4        # Réserve de l'espace sur la pile
    	sw $t4, 0($sp)           # Sauvegarde de $ra sur la pile
	jal check_sudoku	 # permet d'invalider un chiffre plus rapidement
	bne $s0, 0, verif_grille_suite	# si invalide, on passe au chiffre suivant
    	jal solve_sudoku		# on vérifie le sudoku
    verif_grille_suite:
    	lw $t4, 0($sp)           # Restaure l'adresse de retour
    	addi $sp, $sp, 4         # Libère l'espace sur la pile
    	lw $t3, 0($sp)           # Restaure l'adresse de retour
    	addi $sp, $sp, 4         # Libère l'espace sur la pile
    	lw $t2, 0($sp)           # Restaure l'adresse de retour
    	addi $sp, $sp, 4         # Libère l'espace sur la pile
    	lw $t1, 0($sp)           # Restaure l'adresse de retour
    	addi $sp, $sp, 4         # Libère l'espace sur la pile
    	beq $s5, 1, sudoku_fini	#si le sudoku est juste on peut continuer
    	addi $t4, $t4, 1	#on incrémente le nombre et on recommence
    	li $t5, 32              # Remet un ' ' dans la case si solution incorrecte (qui équivaut a un 0)
    	sb $t5, ($t2)           # Réinitialise la case à vide après l'échec
    	j verif_grille
    sudoku_fini:
    	lw $ra, 0($sp)           # Restaure l'adresse de retour
    	addi $sp, $sp, 4         # Libère l'espace sur la pile
    	jr $ra
    	
    parcours_fini:		#finit là quand la grille est complète
    jal check_sudoku		#teste le sudoku complet
    beq $s0, 0, fini_et_juste	#si il est tout juste
    j y_a_pas_de_solutions	#sinon il n'est pas juste
    
    fini_et_juste:		#finit là si la grille est juste
    jal displayGrille		#affiche le sudoku en version linéaire
    jal addNewLine		#saute une ligne
    jal displaySudoku		#affiche le sudoku
    li $s5, 1			#on dit qu'il est correct en mettant $s5 a 1
    lw $ra, 0($sp)           	# Restaure l'adresse de retour
    addi $sp, $sp, 4        	# Libère l'espace sur la pile
    jr $ra
    
    y_a_pas_de_solutions:	#là où ça finit si la grille est fausse
    li $s5, 2			#on dit qu'il est pas correct en mettant $s5 a 2
    lw $ra, 0($sp)           	# Restaure l'adresse de retour
    addi $sp, $sp, 4         	# Libère l'espace sur la pile
    jr $ra			#on s'arrête
    

# ------ Fonction loadFile -----
# ouvre un fichier passé en argument
# ouvrir un fichier passé en argument : appel systeme 13 
# 	$a0 nom du fichier
#	$a1 (= 0 lecture, = 1 ecriture)
# Registres utilises : $v0, $a2
loadFile:
    li $v0, 13
    li $a2, 0
    syscall
    jr $ra
    
# ----- Fonction closeFile ------
# ferme un descripteur de fichier
# Fermer le fichier : appel systeme 16
#	$a0 descripteur de fichier  ouvert
# Registres utilises : $v0
closeFile:
    li	$v0, 16	
    syscall
    jr 	$ra
    
# ----- Fonction parseValues -----
# extrait l'ensemble des valeurs du Sudoku à partir du fichier spécifié en paramètre.
# Registres utilises : $v0, $a[0-2], $t[0-2]
parseValues:
    la $a0, fichier	# Charge l'adresse du fichier à lire dans $a0
    li $a1, 0		# Mode d'ouverture (0 = lire)
    move $t7, $ra
    jal loadFile		# Appel de la fonction loadFile
    move $ra, $t7
    move $t3, $v0		# Stockage du descripteur de fichier dans $t3
    li      $t0, 0		# Initialisation de l'indice pour parcourir le tableau
    boucle_lecture:		# Boucle
    
        beq  $t0, 81, end_lecture	# On s'arrête quand l'indice 81 est atteint
        
        move $a0, $t3		# Descripteur de fichier dans a0 pour l'appel système 14
        la $a1, buffer		# Endroit où stocker le caractère qui sera lu
        li $a2, 1		# Nombre d'octet à lire
        li $v0, 14		# Appel système 14 : lecture de $a2 octets (1 pour 1 caractère) depuis $a0 (fichier ouvert) puis stockage dans $a1 (buffer)
        syscall
        
        la $t1, grille		# Adresse du début de la grille
        add $t1, $t1, $t0	# Ajout de l'indice à l'adresse (+1 octet * adresse)
        lb $t2, buffer		# Charger le caractère dans $t2
        sb $t2, 0($t1)		# stocker la valeur de $t2 (le caractère lu) à l'adresse $t1
        
        addi $t0, $t0, 1	# Incrémentation de l'indice
        
        j boucle_lecture	# Boucle
    end_lecture:
    move $t7, $ra
    jal closeFile		# Appel de la fonction closeFile
    move $ra, $t7
    jr $ra
    
# ----- Fonction zeroToSpace -----
# convertit les 0 (cases vides) de votre grille en espace. 
# Note : la fonction displayGrille a été modifiée pour afficher les espaces en tant que caractère et non entier
# registres utilisés : $t[0-3]
zeroToSpace:
    la $t0, grille				# charge l'adresse de la grille dans $t0
    li $t1, 0
    parcours_grille:
        beq $t1, 81, end_parcours_grille	# boucle for de 0 à 81
        add $t2, $t0, $t1			# adresse de l'élément à l'indice $t1 de la grille dans $t2
        lb $t3, ($t2)				# chargement de la valeur de l'élément à l'adresse $t2 dans $t3
        beq $t3, 48, transform_space		# si cette valeur vaut 48 (0 en ASCII), on le transforme en espace
        j end_transform_space			# sinon on saute après
        transform_space:
             li $t3, 80				# valeur ASCII de l'espace (32) + 48 à cause de la fonction transformAsciiValues qui enlèvera 48
             sb $t3, ($t2)			# stockage de la nouvelle valeur dans la grille
        end_transform_space:
             addi $t1, $t1, 1			# Incrémentation de l'indice
             j parcours_grille
    end_parcours_grille:
         jr $ra
         
# ----- Fonction displaySudoku -----
# affiche le sudoku plus joliment que displayGrille
# registres utilisés : $v0, $a0, $t0 (adresse de la grille), $t1 (compteur de ligne), $t2 (adresse du caractère lu), $s1 (compteur de colonne), $t[5-7] (sauvegarde de l'adresse de retour)
displaySudoku:
    la $t0, grille				# sauvegarde de l'adresse du début de la grille
    li $t1, 0					# compteur de lignes
    boucle_display_sudoku:
        move $t5, $ra				# sauvegarde de l'adresse de retour
        jal ligne_nombres			# affichage d'une ligne de nombres
        move $ra, $t5				# restitution de l'adresse de retour
        beq $t1, 8, end_display_sudoku		# si dernière ligne, pas de ligne de transition
        move $t5, $ra
        jal ligne_transition			# affichage d'une ligne pour séparer les nombres
        move $ra, $t5
        addi $t1, $t1, 1			# ligne suivante
        j boucle_display_sudoku
end_display_sudoku:
    jr $ra

# ----- Fonction ligne_nombre -----
# affiche une ligne de 9 nombres du sudoku séparés par des |
# registres utilisés : mêmes registres que displaySudoku
ligne_nombres:
    li $s1, 0					# compteur de colonne
    boucle_ligne_nombres:
        mul $t2, $t1, 9				# 9x le numéro de ligne (pour savoir l'adresse de la ligne)
        add $t2, $t0, $t2			# adresse de la ligne
        add $t2, $t2, $s1			# numéro de colonne ajouté à l'adresse de la ligne
        lb $a0, ($t2)				# sauvegarde du nombre dans a0
        beq $a0, 32, affiche_ligne_char	   	# si a0 est un espace, l'afficher en tant que caractère
        li $v0, 1                  		# code pour l'affichage d'un entier
        j end_affiche_ligne_char
        affiche_ligne_char:
            li $v0, 11		    		# code pour l'affichage d'un caractère ascii
        end_affiche_ligne_char:
        syscall
        beq $s1, 8, end_ligne_nombres		# si dernière colonne, pas de pipe
        li $v0, 11				# code pour l'affichage d'un caractère
        li $a0, 124				# 124 : code ASCII de |
        syscall
        add $s1, $s1, 1				# nombre suivant
        j boucle_ligne_nombres
end_ligne_nombres:
    move $t6, $ra
    jal addNewLine				# ajout d'un caractère retour à la ligne
    move $ra, $t6
    jr $ra

# ----- Fonction ligne_transition -----
# affiche une ligne de transition : -+-+-+-+-+-+-+-+-
# registres utilisés : mêmes registres que displaySudoku
ligne_transition:
    li $s1, 0					# compteur de colonne
    boucle_ligne_transition:
        li $v0, 11				# code pour l'affichage d'un caractère
        li $a0, 45				# 45 : code ASCII de -
	syscall
        beq $s1, 8, end_ligne_transition	# si dernière colonne, pas de +
        li $v0, 11				# code pour l'affichage d'un caractère
        li $a0, 43				# 45 : code ASCII de +
        syscall
        add $s1, $s1, 1				# caractère suivant
        j boucle_ligne_transition
end_ligne_transition:
    move $t7, $ra
    jal addNewLine				# ajout d'un caractère retour à la ligne
    move $ra, $t7
    jr $ra
#                                               #
#                                               #
# Fonction !!!                                  #  
#                                               #
#                                               #
#                                               #
################################################# 





exit: 
    li $v0, 10
    syscall
