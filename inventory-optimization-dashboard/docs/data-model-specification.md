# Spezifikation des Datenmodells: Dashboard zur Optimierung des Warenbestands

## 1. Übersicht und Architekturstrategie  
Diese Spezifikation definiert den Migrationspfad für das Datenmodell von einer Legacy-Architektur **SAP ECC6 (Open SQL)** zu einem optimierten Umfeld in **S/4HANA Cloud**, wobei **CDS Views** eingesetzt werden.  

Ziel ist der Ersatz komplexer `SELECT`-Anweisungen durch deklarative CDS-Ansichten, die Rechenleistung direkt im HANA-Speicher nutzen und damit hohe Performance für das Fiori Elements-Frontend gewährleisten. Das Modell priorisiert:  
*   **Analytische Dichte:** Kombination von Stammdaten (Materialien/Lieferanten) mit Transaktionsdaten (Bestände/Bewegungen).  
*   **Prädiktive Bereitschaft:** Vorbereitung spezifischer Felder für ML/Machine-Learning-Algorithmen zur Bestandsoptimierung.  
*   **Cloud-native Integration:** Sicherstellung, dass Entitäten über OData v4-kompatible Dienste exponiert werden.  


---

## 2. Definitionen der Kern-Entitäten (CDS View Struktur)


### 2.1 `Z_INV_OPT_HEADER`
**Zweck**: Hochwertige Dashboard-Aggregation zur Bereitstellung von Bestandszuständen und wesentlichen KPIs pro Lagerortgruppe. Ersetzt die traditionellen Report-Köpfe in SAP ECC.  

Datei: `/inventory-optimization-dashboard/legacy_group_examples/Z_INV_OPT_HEADER.abap`


### 2.2 `Z_MAT_STOCK_DETAILS` (Die "Widetable")  
**Zweck**: Detaillierte Transaktionsansicht, der aktuelle Bestände über alle Lagerorte und Werk aufschlüsselt. Entwickelt zur Nutzung durch Fiori List Reports oder Analysis-Seiten. Diese Ansicht erspart das Anbinden mehrerer Tabellen in ABAP-Code, indem die Joins nun direkt in die CDS-Logik verlagert werden.  

Datei: `/inventory-optimization-dashboard/legacy_group_examples/Z_MAT_STOCK_DETAILS.abap`

