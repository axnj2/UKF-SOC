# Uncentered Kalman Filter for estimating SOC

This repository aims to verify the claim from (Plett 2011) that UKF are incensitive to the total capacity of the battery when estimating the State Of Charge (SOC).




## results
Sans correction (modèle interne batterie de capacité 1) et batterie avec capacité de 0.3 la capacité initiale.
![](image.png)
Avec correction toute les secondes 
![](image-1.png)

## next step
Comment traiter le bruit sur le courant
un bruit de +- 30 mA est raisonnable pour un BMS

De plus lors du veillissement, l'inverse de la constante de temps diminue de +- 30% sur 4000 cycles (Couto et al. 2025).
$\frac{1}{\tau'} = (1-x) \frac{1}{\tau}$ donc $\tau' =\frac{1}{1-x} \tau$

Traiter des erreur d'offset sur le courant

Traiter des données expérimentales

## References

Plett, Gregory L. 2011. ‘Recursive Approximate Weighted Total Least Squares Estimation of Battery Cell Total Capacity’. Journal of Power Sources 196 (4): 2319–31. https://doi.org/10.1016/j.jpowsour.2010.09.048.

Couto, Luis D., Jorn Reniers, Dong Zhang, David A. Howey, and Michel Kinnaert. 2025. ‘Degradation Monitoring and Characterization in Lithium-Ion Batteries via the Asymptotic Local Approach’. IEEE Transactions on Control Systems Technology 33 (1): 189–206. https://doi.org/10.1109/TCST.2024.3483093.
