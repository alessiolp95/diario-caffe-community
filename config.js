// Collegamento all'archivio Supabase della community.
// La chiave "publishable" (o "anon") è fatta per stare nel codice del sito:
// i dati sono protetti dalle regole del database (vedi supabase/schema.sql).
// Sostituisci i due valori con quelli del progetto Supabase della community
// (Project Settings → API Keys). Li usa anche l'azione di keep-alive.
window.DIARIO_CONFIG = {
  supabaseUrl: "https://INSERISCI-ID-PROGETTO.supabase.co",
  supabaseKey: "INSERISCI-CHIAVE-PUBLISHABLE",
};
