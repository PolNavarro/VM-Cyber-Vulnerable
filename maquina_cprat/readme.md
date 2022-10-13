# Maquina CPRAT

Maquina vulnerabilidad apache.

## Crearla en docker
Para iniciar imagen docker:
```bash
docker build .
```
## Crearla en una maquina virtual

1-Crea una màquina virtual amb un Debian 11 (sense interfície gràfica)</br >
2-Entra a la màquina virtual amb l'usuari root</br >
3-Assegurat que la màquina té una IP dins el rang 192.168.0.0/16</br >
4-Fes un snapshot de la teva màquina virtual per si algo no surt bé</br >
5-Descarregat (o copia manualment) el script "install.sh"</br >
6-Fes que el script sigui executable (chmod u+x install.sh)</br >
7-Executa el script per iniciar la configuració de la màquina (./install.sh)</br >
8-Guanya accés al WordPress per completar la màquina.</br >