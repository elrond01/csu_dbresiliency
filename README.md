# Microhack Resiliency DB SQL Server (failover group)

### [Prerequisitos](#prerequisitos)

### [Reto 1: Crear servidor primario de base de datos, servidor secundario y failover group](#reto-1-crear-servidores-sql-failover)

### [Reto 2: Crear balanceador global y functions](#reto-2-crear-balanceadorglobal-functions)

## General
El proposito de este microhack es demostrar el uso del failover group como mecanismo de resiliencia para bases de datos sql [FailOver Group Best Practices](https://learn.microsoft.com/en-us/azure/azure-sql/database/auto-failover-group-sql-db?view=azuresql&tabs=azure-powershell) y la interaccion con una app simulada en dos Functions con un balanceador global.

IMAGEN ARQUITECTURA

# Prerequisitos

## Tarea 1: Desplegar las plantillas bicep 

Para desplegar el ambiente base utilizaremos bicep y va a ser deplegada en su subscripcion de azure en east us y su correspondiente region par west us para el DR tanto de nuestra base de datos como de nuestra aplicacion

- logearse a cloud shell (Powershell)

`Cd clouddrive`

- Clonar el repo 

`git clone https://github.com/elrond01/csu_dbresiliency.git`

- Ejecutar ./deploy.ps1

`cd ./csu_dbresiliency`

`./deploy.ps1`

- al final del despliegue se es presentado el nombre del failovergroup, necesario para la configuracion de la app

-username:adminuser

-pass:SqlPasswd1234567
