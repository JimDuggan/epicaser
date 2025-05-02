# epicaser
A package to generate an epi case signal (based on an SIR model) for input to queuing/forecasting models. 

It also generate values for the number of available healthcare resources, which deplete in proportion to the attack rate of the pathogen.

It generates synthetic individualised records for hospital patients.

To install the package, type the following code:
```
devtools::install_github("JimDuggan/epicaser")
```

To see how to use the package for:

* generating epi cases, [click here](https://github.com/JimDuggan/epicaser/tree/main/data-raw/Epi)

* generating hospital (individual) cases, [click here](https://github.com/JimDuggan/epicaser/tree/main/data-raw/Hospital)

Code examples can be seen [here](https://github.com/JimDuggan/epicaser/tree/main/inst)

### Change history

* Initial version February 15th 2024, generated epi cases
* December 12th 2024, Version 1.1, adding staff as a resource whose availability can be impacted by the disease attack rate
* May 1st 2025, adding individualisation to model outputs that generate (1) a case list based on SIR model incidence and (2) synthetic hospital data.

### Project Information

This work is part of the [RAPIDE Project](https://www.rapideproject.eu) Work Package 3 (Forecasting and planning of patients and resources over the healthcare chain).

Project Details:

* **Project No.** 101136348
* **EC Contribution:** Euro 5,916,977.50
* **Duration:** 48 months
* **Start date:** 1 January 2024

RAPIDE is funded by the European Union’s Horizon Europe Research and Innovation programme, with the following partners.

<p align="center" width="100%">
    <img width="100%" src="RAPIDE.png">
</p>

