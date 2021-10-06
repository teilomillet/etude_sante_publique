 # Creation des tables
 CREATE TABLE population2 (
		pays VARCHAR(60) NOT NULL,
        code_pays SMALLINT UNSIGNED NOT NULL,
        annee SMALLINT UNSIGNED NOT NULL,
        population INT UNSIGNED,
        PRIMARY KEY (code_pays, annee)
        )
        ENGINE=INNODB;

 CREATE TABLE dispo_alim2 (
		pays VARCHAR(60) NOT NULL,
        code_pays SMALLINT UNSIGNED NOT NULL,
		annee_alim SMALLINT UNSIGNED NOT NULL,
        code_produit SMALLINT UNSIGNED NOT NULL,
        produit VARCHAR(60) NOT NULL,
        origine VARCHAR(60),
        dispo_alim_tonnes FLOAT(12,2),
        dispo_alim_kcal_p_j FLOAT(12,2),
        dispo_prot FLOAT(12,2),
        dispo_mat_gr FLOAT(12,2),
        PRIMARY KEY (code_pays, code_produit, annee_alim)
        )
        ENGINE=INNODB;

        
 CREATE TABLE equilibre_prod2 (
		pays VARCHAR(60) NOT NULL,
        code_pays SMALLINT UNSIGNED NOT NULL,
        annee SMALLINT UNSIGNED NOT NULL,
        produit VARCHAR(60) NOT NULL,
        code_produit SMALLINT UNSIGNED NOT NULL,
        dispo_int FLOAT(12,2),
        alim_anim FLOAT(12,2),
        Semences FLOAT(12,2),
        Pertes FLOAT(12,2),
        Traitement FLOAT(12,2),
        Nourritures FLOAT(12,2),
        autres_usages FLOAT(12,2),
        PRIMARY KEY (code_pays, code_produit, annee)
        )
        ENGINE=INNODB;    

 CREATE TABLE sous_nutrition2 (
        pays VARCHAR(60) NOT NULL,
        code_pays SMALLINT UNSIGNED NOT NULL,
        annee SMALLINT UNSIGNED NOT NULL,
        nb_personnes INT,
        PRIMARY KEY (code_pays, annee)
        )
        ENGINE=INNODB;        

# Import des CSV        
LOAD DATA INFILE '/Users/teilo/Desktop/data/population2.csv'
INTO TABLE population2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES terminated by '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/Users/teilo/Desktop/data/dispo_alim.csv'
INTO TABLE dispo_alim2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES terminated by '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/Users/teilo/Desktop/data/equilibre_prod.csv'
INTO TABLE equilibre_prod2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES terminated by '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE '/Users/teilo/Desktop/data/sous_nutrition2.csv'
INTO TABLE sous_nutrition2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES terminated by '\n'
IGNORE 1 ROWS;

       # 19   n1 TOP 10 prot/kcal // habitant
 SELECT annee_alim as year, pays, SUM(prot_dispo / 1000 * 365) as prot_dispo_par_humain
                FROM dispo_alim2
                WHERE annee_alim='2013'
                GROUP BY annee_alim, pays
                ORDER BY prot_dispo_par_humain DESC
                LIMIT 10;        
                
 SELECT annee_alim as year, pays, SUM(dispo_kcal_p_j * 365) as kcal_dispo_par_humain
                FROM dispo_alim2
                WHERE annee_alim='2013'
                GROUP BY annee_alim, pays
                ORDER BY kcal_dispo_par_humain DESC
                LIMIT 10;                    


# 19 n2 BOT 10 prot // habitant
SELECT annee_alim as year, pays, SUM(prot_dispo / 1000 * 365) as prot_dispo_par_humain
                FROM dispo_alim2
                GROUP BY annee_alim, pays
                HAVING annee_alim= '2013'
                ORDER BY prot_dispo_par_humain ASC
                LIMIT 10;
                
# 19 n3 TOTAL PERTES // PAYS 2013                
SELECT annee as year, pays, SUM(Pertes * 1000000) as Pertes
                FROM equilibre_prod2
                WHERE annee_alim = '2013'
                GROUP BY annee, pays
                ORDER BY Pertes DESC;

# 19 n4 TOP 10 pays // sous nutrition                
SELECT sous_nutrition2.annee as year, sous_nutrition2.pays as pays, sous_nutrition2.nb_personnes as sousnut, population.population as population, (sous_nutrition2.nb_personnes / population.population) as ratio
	FROM sous_nutrition2
	LEFT JOIN population on sous_nutrition2.code_pays = population.code_pays AND sous_nutrition2.annee = population.annee
	WHERE annee = '2013'
	ORDER BY ratio DESC
	LIMIT 10;

        

# 19 n5 TOP 10 PRODUITS autres usages // dispo interieur
SELECT Produit,
		SUM(autres_usages) as autres,
        SUM(dispo_int) as dispo,
        SUM(autres_usages) / SUM(dispo_int) as ratio
	FROM equilibre_prod
	WHERE annee = '2013'
    GROUP BY Produit
    ORDER BY ratio DESC
    LIMIT 10;

