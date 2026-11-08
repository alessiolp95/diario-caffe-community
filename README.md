# Diario caffè · Community

Versione condivisa del Diario caffè per una piccola community di appassionati.

- **Catalogo condiviso**: le schede dei caffè (nome, torrefazione, origine, varietà, processo, profilo, note dichiarate, foto)
  sono visibili a tutti i membri. Chi compra un caffè già catalogato lo aggiunge alla propria dispensa con un tocco.
  Una scheda la modificano chi l'ha creata e gli amministratori, e non si può eliminare finché qualcuno la ha in dispensa.
- **Dati personali privati**: data di tostatura, peso, prezzo, macinini e macchine li vede solo chi li ha inseriti (dei macinini la community vede solo i modelli, in forma anonima, come modelli pronti);
  le estrazioni anche, salvo quelle che si sceglie di condividere nella Community.
- **Macinini personalizzati**: marca, modello, macine (standard o un nome a scelta), valore minimo, massimo e step minimo. Nel modulo "Nuovo macinino" si può partire da un modello già usato da altri membri (funzione `grinder_presets` del database: restituisce solo marca, modello, macine, scala e quanti membri lo usano, mai chi).
- **Ruota degli aromi**: pagina di consultazione (dalla libreria, indirizzo `#ruota`) e campo "Aromi percepiti" nel modulo estrazione, in italiano o in inglese, con scelta a ogni livello della Coffee Taster's Flavor Wheel (SCA/WCR). Gli aromi si salvano nell'estrazione (`aromas`), compaiono nella Community e nell'immagine da condividere.
- **Predefiniti per metodo**: ognuno può salvare i propri valori di partenza (dose, resa/acqua, temperatura, macinino e macinatura…).
- **Macchine espresso**: ognuno registra le proprie (marca facoltativa, modello) e le sceglie negli espressi.
- **Community**: salvando un'estrazione si può spuntare "Condividi nella Community" (disattivato di default).
  Le estrazioni condivise compaiono nella sezione Community, con autore, caffè, parametri, voto e note;
  restano modificabili solo da chi le ha fatte.
- **Condividi come immagine**: ogni estrazione (propria o della Community) diventa un'immagine 1080×1350
  con caffè, foto della confezione, parametri, voto e commento, da salvare o inviare.

Web app installabile su iPhone, Android e computer, ospitata su GitHub Pages, con i dati su Supabase (piano gratuito).

## Com'è fatta

- `index.html`: tutta l'app.
- `legal.js`: informativa privacy e condizioni d'uso.
- `fonts/`: caratteri ospitati sul sito.
- `config.js`: indirizzo e chiave pubblica del progetto Supabase.
- `sw.js`, `manifest.webmanifest`, `icons/`: installazione nella schermata Home e funzionamento offline (sola lettura).
- `vendor/`: libreria Supabase (versione 2.117.3), inclusa nel sito così funziona anche offline.
- `supabase/schema.sql`: tabelle, regole di sicurezza e cartella delle foto.
- `.github/workflows/keep-alive.yml`: evita che il progetto Supabase gratuito vada in pausa.

## Configurazione (una volta sola)

### 1. Supabase

1. Su [supabase.com](https://supabase.com) crea un **nuovo progetto** (separato da quello personale; il piano gratuito ne permette 2 attivi).
2. **SQL Editor** → New query → incolla `supabase/schema.sql` → Run.
3. **Authentication → Sign In / Providers**: disattiva "Allow new users to sign up" (si entra solo su invito).
4. **Authentication → URL Configuration**: in "Site URL" metti l'indirizzo GitHub Pages
   (es. `https://alessiolp95.github.io/diario-caffe-community/`) e aggiungilo anche in "Redirect URLs".
5. **Project Settings → API Keys**: copia l'URL del progetto e la chiave *publishable* dentro `config.js`.

### 2. Email (per inviti e "Password dimenticata?")

Il servizio email incluso in Supabase consegna solo agli indirizzi del team del progetto e pochi messaggi l'ora,
quindi per gli inviti serve un SMTP proprio. Gratis vanno bene, per esempio, Brevo o Gmail (con una "password per le app").
Si configura in **Authentication → Emails → SMTP Settings** → Enable custom SMTP.

Se preferisci non configurarlo: crea gli utenti a mano (vedi sotto, opzione B) e comunica tu la password.
In quel caso "Password dimenticata?" non funziona: la reimposti tu dalla dashboard.

### 3. GitHub Pages

Repository → Settings → Pages → "Deploy from a branch", ramo `main`, cartella `/ (root)`.
In Actions controlla che l'azione "Tieni attivo Supabase" sia abilitata (puoi lanciarla a mano con "Run workflow").

## Aggiungere un membro

- **A. Con invito via email** (serve l'SMTP): Authentication → Users → Add user → *Send invitation*.
  Il membro riceve un link, apre l'app e sceglie la sua password.
- **B. A mano**: Authentication → Users → Add user → *Create new user*, con "Auto Confirm User" attivo.
  Comunica email e password al membro.

Al primo accesso l'app chiede il nome da mostrare accanto ai caffè aggiunti al catalogo e propone di aggiungere il macinino.

Per togliere un membro: Authentication → Users → elimina l'utente. Le sue confezioni ed estrazioni vengono cancellate;
le schede che aveva creato restano nel catalogo (senza autore, modificabili solo dalla dashboard).

## Privacy e condizioni d'uso

I testi sono in `legal.js`: informativa privacy, condizioni d'uso, riepilogo e email di contatto (`CONTACT`).
Al primo accesso ogni membro deve spuntare "Ho letto e accetto" (salvato nell'account come `termsAccepted`).
Se si cambiano i testi in modo sostanziale, aggiornare `VERSION` in `legal.js`: al prossimo accesso tutti
dovranno accettare di nuovo. La pagina completa è raggiungibile anche senza login (`#info`), dal link nella
schermata di accesso e dal piè di pagina.

I caratteri (Bricolage Grotesque, IBM Plex Sans e Mono, licenza SIL OFL 1.1) sono in `fonts/`, ospitati sul sito:
nessuna richiesta a Google Fonts.

## Amministratori

Gli amministratori possono modificare ed eliminare tutte le schede del catalogo (foto comprese), anche quelle create da altri.
Si nominano solo da Supabase → SQL Editor, mai dall'app:

```sql
insert into public.admins select id from auth.users where email = 'nome@esempio.it';
-- per togliere il ruolo:
delete from public.admins where user_id = (select id from auth.users where email = 'nome@esempio.it');
```

## Doppioni nel catalogo

- Quando si crea una scheda molto simile a una esistente (nome e torrefazione, anche scritta diversamente),
  l'app mostra le due schede affiancate e chiede "È lo stesso caffè?": si può usare quella del catalogo o crearne una nuova.
- Il campo torrefazione suggerisce quelle già presenti.
- Ogni membro può usare "Segnala doppione" dalla scheda di un caffè.
- Gli amministratori trovano in Impostazioni → Catalogo → "Possibili doppioni" le coppie segnalate e quelle trovate
  automaticamente. Per ogni coppia vedono le differenze (con un avviso se processo, varietà, profilo o torrefazione
  sono diversi), scelgono la scheda da tenere e uniscono: confezioni ed estrazioni di tutti passano alla scheda tenuta,
  i suoi campi vuoti vengono completati con l'altra, che viene eliminata. Oppure segnano la coppia come "Non sono doppioni".
- L'unione la fa il database (funzione `merge_catalog`, solo amministratori), in un'unica operazione.

## Backup

Il piano gratuito di Supabase non fa copie automatiche. Ogni membro può usare "Esporta backup" in fondo alla libreria
(file con le sue confezioni, le schede del catalogo collegate con le foto, le estrazioni e i macinini) e "Importa backup".
"Importa backup" accetta anche l'esportazione di Beanconqueror (Impostazioni → Esporta, file `Beanconqueror.zip` o `Beanconqueror.json`):
una schermata propone gli abbinamenti (scheda del catalogo nuova o esistente, metodo, macinino) prima di importare.
Le foto non sono incluse nell'esportazione di Beanconqueror; gli aromi passano sulla ruota SCA, quelli senza equivalente vanno nelle note,
e reimportare lo stesso file non crea doppioni.
"Importa backup" accetta anche i backup della versione personale del Diario caffè: ogni caffè diventa una scheda del catalogo
(o viene collegato a una scheda già presente con lo stesso nome e torrefazione) più una confezione in dispensa,
e i macinini Pietro e Hibrew G5 vengono creati in automatico.

## Limiti del piano gratuito

Supabase: 500 MB di database, 1 GB di foto, 5 GB di traffico al mese, 50.000 utenti attivi al mese, pausa dopo 7 giorni
senza attività (evitata dall'azione di keep-alive). GitHub Pages: sito fino a 1 GB, 100 GB di traffico al mese.
Le foto vengono ridimensionate a 1400 px prima del caricamento (in genere 150–300 KB l'una).
