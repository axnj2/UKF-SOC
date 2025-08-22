# Uncentered Kalman Filter for estimating SOC

This repository aims to verify the claim from (Plett 2011) that UKF are incensitive to the total capacity of the battery when estimating the State Of Charge (SOC).




## results
Sans correction (modèle interne batterie de capacité 1) et batterie avec capacité de 0.3 la capacité initiale.
![](image.png)
Avec correction toute les secondes 
![](image-1.png)


Avec un modèle du premier order pour l'UKF sur des donnés de SPMe avec une batterie veillie de capacitée réduite de moitié et une constante de temps doublée (utilise un drive cycle ) sans bruit ajouté :  (`src/test_state_estimation_with_ukf.m`) 
![alt text](image-3.png)
Le courant d'entrée : 
![alt text](image-4.png)

Conclusion : Pour peu que les paramètres de l'UKF sont correctement ajusté (process noise, measurement noise et initial state variance) le SOC de la batterie est bien estimé (ordre de grandeur de l'erreur : 3% en général avec du bruit) même si elle a veilli et que sa capacité et dynamique est différente du modèle utilisé

## next step
Comment traiter le bruit sur le courant
un bruit de +- 30 mA est raisonnable pour un BMS

Traiter des erreur d'offset sur le courant

## References

Plett, Gregory L. 2011. ‘Recursive Approximate Weighted Total Least Squares Estimation of Battery Cell Total Capacity’. Journal of Power Sources 196 (4): 2319–31. https://doi.org/10.1016/j.jpowsour.2010.09.048.

Couto, Luis D., Jorn Reniers, Dong Zhang, David A. Howey, and Michel Kinnaert. 2025. ‘Degradation Monitoring and Characterization in Lithium-Ion Batteries via the Asymptotic Local Approach’. IEEE Transactions on Control Systems Technology 33 (1): 189–206. https://doi.org/10.1109/TCST.2024.3483093.
