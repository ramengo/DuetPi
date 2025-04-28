# Stage: elementotc

Questo stage pi-gen configura:

1. **Stampanti**: elementotc, 3dforme, beta  
2. **Node-RED**: installazione e dipendenze  
3. **Nodi aggiuntivi**: installazione di nodi custom

## Variabili d'ambiente

- `TARGET_PRINTER`: uno tra `elementotc`, `3dforme`, `beta`

## Aggiunta in STAGE_LIST

```bash
STAGE_LIST="... elementotc"
```

## Esecuzione build

```bash
TARGET_PRINTER=elementotc ./build-docker.sh
```

## Compatibilità

- Raspberry Pi OS Buster (armhf) su Raspberry Pi 4  
- Controllo architettura e OS all'inizio dello stage
