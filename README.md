# rai.tv-media-downloader

This software is intended to be mainly used from Italian persons.
This document is therefore written in Italian language.
Nevertheless, code and included comments are in English language.

###Descrizione

Questo semplice script permette di scaricare contenuti dal sito [rai.tv](http://rai.tv).

Si tratta di una prima versione dello script, migliorabile in termini di leggibilità del codice e ottimizzazione.

###Utilizzo

Da una shell Bash, lanciare il programma con il seguente comando:

```sh
bash rai.sh [-s] <search_string>
```

dove il parametro `-s`, opzionale, identifica la ricerca di un episodio di una (mini) serie.
Il parametro `<search_string>` identifica invece la ricerca da eseguire.

Un esempio di ricerca è il seguente:

```sh
bash rai.sh -s Non dirlo al mio capo
```

Per ogni episodio trovato, verrà richiesto se si intende memorizzarlo/scaricarlo su disco oppure no.
In caso affermativo, l'episodio verrà salvato all'interno della stessa directory dello script.

###L'exploit (e come migliorare la piattaforma Rai)

####Recupero dei metadati

Proprio come avviene con il sito Rai e le app mobile, lo script comunica direttamente con le API fornite dal sito Rai per poter recuperare informazioni sui contenuti in formato XML.
L'indirizzo utilizzato per ottenere la lista di contenuti in formato XML è il seguente.

```
http://www.rai.tv/ricerca/search?q=$SEARCH&sort=date:D:L:d1&filter=0&getfields=*&site=raitv&client=rai_tv2&start=0
```

dove il parametro `$SEARCH` (parametro `q` passato via HTTP) identifica la stringa ricercata.

A giugno 2016, il sito ufficiale Rai utilizza tale strumento di ricerca per la ricerca di contenuti all'interno della piattaforma [rai.tv](http://rai.tv).

####Protezione dei contenuti
Nel caso in cui il fornitore del servizio intendesse proteggere in modo più appropriato i propri contenuti è possibile come descritto (brevemente) di seguito.
Sebbene i metodi suggeriti portino ad un incremento della sicurezza, essi non forniscono protezione da attacchi avanzati (es. compromissione dei server o nodi vulnerabili, wrapping di librerie, ecc.).

#####Utilizzo del protocollo HTTPS
Un primo approccio, relativamente rapido ed indolore, prevede l'adozione di una connessione sicura di tipo HTTPS per il recupero dei feed.
Questo non protegge da eventuali analisi client-side, ma protegge da eventuali operazioni effettuate a livello di rete.

#####Controllo dei certificati SSL lato client
Per quanto riguarda le app per dispositivi mobili, è possibile evitare attacchi di tipo man-in-the-middle su protocollo HTTPS effettuando un controllo lato client dei certificati SSL del server Rai.
Tale approccio richiede l'installazione dei certificati all'interno della app.
In aggiunta, tecniche di code-ofuscation dovrebbero essere adottate per proteggere la app.

#####Pagine web dinamiche e contenuti ad-hoc legati alla sessione
Lato web, il recupero dei contenuti potrebbe essere generato dinamicamente lato server (con recupero dinamico, o generazione, lato client della porzione di pagina che mostra i contenuti) evitando al client una comunicazione diretta con il servizio che fornisce le API.
In questo modo il client non potrebbe conoscere l'identità del fornitore di API, attraverso una analisi del traffico generato dalla piattaforma web del servizio.

Inoltre, maggiore sicurezza sarebbe fornita in questo caso da una generazione dinamica dell'URL del contenuto multimediale, vincolandolo alla specifica sessione o associandogli una durata/scadenza temporale.
In questo modo, non sarebbe possibile per l'utente condividere l'URL di un video, una volta noto l'indirizzo.

###Disclaimer

Si assume che gli utilizzatori del programma siano abbonati al servizio Rai.
Non sono responsabile per ogni utilizzo illecito del programma fornito.

###Contatti

Sono disponibile su Twitter come [@auino](https://twitter.com/auino).
