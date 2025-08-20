# Uncentered Kalman Filter for estimating SOC

This repository aims to verify the claim from (Plett 2011) that UKF are incensitive to the total capacity of the battery when estimating the State Of Charge (SOC).



## References

Plett, Gregory L. 2011. ‘Recursive Approximate Weighted Total Least Squares Estimation of Battery Cell Total Capacity’. Journal of Power Sources 196 (4): 2319–31. https://doi.org/10.1016/j.jpowsour.2010.09.048.

## results
Sans correction (modèle interne batterie de capacité 1) et batterie avec capacité de 0.3 la capacité initiale.
![](image.png)
Avec correction toute les secondes 
![](image-1.png)

## next step
Comment traiter le bruit sur le courant
un bruit de +- 30 mA est raisonnable pour un BMS