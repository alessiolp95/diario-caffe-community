/* Informativa privacy e condizioni d'uso della community.
   Per cambiare l'email di contatto basta modificare CONTACT qui sotto.
   Se si modificano i testi in modo sostanziale, aggiornare VERSION: al prossimo accesso
   ogni membro dovrà accettare di nuovo. */
window.DIARIO_LEGAL = (() => {
  const CONTACT = "alessio.lp95@gmail.com";
  const VERSION = "2026-11-08.2";
  const UPDATED = "8 novembre 2026";
  const mail = '<a href="mailto:' + CONTACT + '">' + CONTACT + "</a>";

  const summary = [
    "È un progetto amatoriale e gratuito, su invito, gestito da Alessio.",
    "Il catalogo dei caffè, il tuo nickname e le estrazioni che scegli di condividere li vedono gli altri membri; dei macinini vedono solo il modello e la scala, come modelli pronti, senza sapere chi li usa; il resto (dispensa, estrazioni non condivise, macchine) è privato.",
    "I dati stanno su Supabase, in un server a Francoforte. Niente pubblicità, statistiche o tracciamento.",
    "Le foto che carichi sono raggiungibili da chi ha il loro link: carica solo foto delle confezioni, scattate da te.",
    "Non ci sono garanzie: fai ogni tanto “Esporta backup”.",
    "Puoi chiedere in ogni momento di cancellare il tuo account scrivendo a " + mail + ".",
  ];

  const privacy = `
<h2>Informativa sulla privacy</h2>
<p class="muted small">Aggiornata il ${UPDATED}</p>

<h3>Chi tratta i tuoi dati</h3>
<p>Diario caffè · Community è un progetto amatoriale e gratuito, riservato a un piccolo gruppo di appassionati invitati. Lo gestisce Alessio, che è il titolare del trattamento. Per qualsiasi domanda o richiesta: ${mail}.</p>

<h3>Quali dati raccogliamo</h3>
<ul>
<li><b>Account</b>: l'indirizzo email con cui sei stato invitato e la password, che è gestita dal servizio di autenticazione in forma cifrata (nessuno può leggerla).</li>
<li><b>Profilo</b>: il nickname che scegli.</li>
<li><b>Contenuti che inserisci</b>: schede dei caffè del catalogo con le foto delle confezioni; confezioni nella tua dispensa (data di tostatura, peso, prezzo); estrazioni con parametri, voti e note; macinini, macchine espresso e valori predefiniti; data dell'ultimo backup e accettazione di queste condizioni.</li>
<li><b>Dati tecnici</b>: come per ogni sito, i fornitori che ospitano l'app registrano nei loro log l'indirizzo IP e informazioni sul browser, per farla funzionare e proteggerla da abusi.</li>
</ul>
<p>Non raccogliamo dati di pagamento né categorie particolari di dati, e non usiamo pubblicità, statistiche di navigazione o strumenti di tracciamento.</p>

<h3>Chi vede cosa</h3>
<ul>
<li><b>Tutti i membri</b> vedono il catalogo dei caffè (con il nickname di chi ha creato ogni scheda), i nickname e le estrazioni che scegli di condividere nella Community spuntando la casella apposita.</li>
<li><b>Dei tuoi macinini</b> gli altri membri vedono solo marca, modello, macine e scala (minimo, massimo, step), proposti come modelli pronti quando aggiungono un macinino, insieme al numero di membri che usano lo stesso modello. Non vedono chi li usa né il resto dei dati.</li>
<li><b>Solo tu</b> vedi la tua dispensa, le estrazioni non condivise, quali macinini usi, le macchine e le impostazioni.</li>
<li><b>Le foto</b> sono conservate in uno spazio raggiungibile tramite link diretto: chi conosce il link di una foto può aprirla anche senza account.</li>
<li><b>Il gestore</b>, per ragioni tecniche, ha accesso all'archivio. Lo consulta solo per manutenzione, per risolvere problemi o su tua richiesta.</li>
</ul>

<h3>Perché e su quale base</h3>
<p>Usiamo i dati per farti accedere all'app e fornirti le sue funzioni: il diario personale e la condivisione con gli altri membri. La base giuridica è l'esecuzione di queste condizioni d'uso, che accetti al primo accesso (art. 6.1.b del GDPR). I dati tecnici servono anche a mantenere il servizio sicuro (legittimo interesse, art. 6.1.f).</p>

<h3>Dove sono e chi ci aiuta</h3>
<ul>
<li><b>Supabase</b> conserva account, contenuti e foto in un server dell'Unione Europea (Francoforte, Germania) e gestisce l'accesso.</li>
<li><b>GitHub</b> (GitHub Pages) ospita i file dell'app che il tuo browser scarica.</li>
</ul>
<p>Entrambi sono società con sede negli Stati Uniti e trattano i dati per nostro conto secondo le proprie condizioni sulla protezione dei dati. Per questo non si può escludere che alcuni dati tecnici transitino fuori dall'Unione Europea. I caratteri e le librerie dell'app sono ospitati sul sito stesso: non vengono fatte richieste ad altri servizi.</p>

<h3>Cosa resta sul tuo dispositivo</h3>
<p>L'app salva sul dispositivo solo ciò che serve a farla funzionare: la sessione di accesso e una copia dei dati per usarla offline. Non usa cookie di profilazione, quindi non serve alcun banner.</p>

<h3>Per quanto tempo</h3>
<p>Conserviamo i dati finché il tuo account è attivo. Se chiedi la cancellazione, eliminiamo account, dispensa, estrazioni, macinini e macchine entro 30 giorni. Le schede del catalogo che hai creato restano a disposizione della community senza il tuo nickname. Se preferisci, le eliminiamo anche, con le loro foto, purché non siano nella dispensa di altri membri. Le copie di backup che hai esportato restano sul tuo dispositivo e le gestisci tu.</p>

<h3>I tuoi diritti</h3>
<p>Puoi chiedere di accedere ai tuoi dati, correggerli, cancellarli, limitarne il trattamento, opporti e riceverli in un formato leggibile: “Esporta backup” ti dà già tutti i tuoi dati in un file. Scrivi a ${mail}. Se ritieni che i tuoi dati siano trattati in modo non corretto, puoi presentare reclamo al Garante per la protezione dei dati personali (<a href="https://www.garanteprivacy.it" target="_blank" rel="noopener">garanteprivacy.it</a>).</p>

<h3>Età</h3>
<p>La community è riservata ai maggiorenni.</p>
`;

  const terms = `
<h2>Condizioni d'uso</h2>
<p class="muted small">Aggiornate il ${UPDATED}</p>

<h3>1. Che cos'è</h3>
<p>Diario caffè · Community è un'app gratuita e amatoriale, senza scopo di lucro, per tenere il diario dei caffè specialty e delle estrazioni e per condividerli con un piccolo gruppo di appassionati. Vi si accede solo su invito del gestore, Alessio.</p>

<h3>2. Il tuo account</h3>
<p>L'account è personale: non condividere la password. Il gestore può sospendere o eliminare un account in caso di uso improprio, avvisando prima quando possibile.</p>

<h3>3. Cosa è condiviso</h3>
<p>Il catalogo dei caffè e i nickname sono visibili a tutti i membri. Le tue estrazioni sono private, salvo quelle per cui spunti “Condividi nella Community”: quelle le vedono tutti i membri, finché non togli la spunta. Le immagini che crei con “Condividi come immagine” le diffondi tu, dove e con chi vuoi.</p>

<h3>4. I contenuti che carichi</h3>
<ul>
<li>Sei responsabile di ciò che inserisci. Carica solo foto scattate da te o che hai il diritto di usare, non immagini prese dai siti delle torrefazioni o di altri.</li>
<li>Non inserire dati personali di altre persone e niente contenuti offensivi, illegali o pubblicitari.</li>
<li>Le schede che aggiungi al catalogo servono a tutta la community: autorizzi gli altri membri a vederle e a usarle per i propri caffè, anche dopo che avrai lasciato la community, salvo tua richiesta di rimozione.</li>
<li>Chi ha creato una scheda e gli amministratori possono correggerla o rimuoverla, per esempio per sistemare errori o doppioni. Il gestore può rimuovere i contenuti che non rispettano queste regole.</li>
</ul>

<h3>5. Nessuna garanzia</h3>
<p>L'app è offerta così com'è, gratuitamente, usando servizi gratuiti di terzi. Può non essere disponibile, cambiare o contenere errori, e i dati potrebbero andare persi: per questo c'è “Esporta backup”, che conviene usare regolarmente. Nei limiti consentiti dalla legge, il gestore non risponde di danni derivanti dall'uso o dall'impossibilità di usare l'app.</p>

<h3>6. Modifiche e chiusura</h3>
<p>Queste condizioni possono cambiare. Se cambiano in modo sostanziale, te lo chiederemo di nuovo al primo accesso. Il gestore può chiudere la community: in quel caso avviserà con un ragionevole anticipo, per lasciarti il tempo di esportare i tuoi dati.</p>

<h3>7. Legge applicabile</h3>
<p>Si applica la legge italiana. Per domande: ${mail}.</p>
`;

  return { CONTACT, VERSION, UPDATED, summary, privacy, terms };
})();
