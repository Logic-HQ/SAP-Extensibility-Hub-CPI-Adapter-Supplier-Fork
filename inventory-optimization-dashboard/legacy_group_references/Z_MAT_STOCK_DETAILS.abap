@AbapCatalog.sqlViewOn: 'SAP_APPL' #
define view Z_mat_stock_details as select from I_MARA { // Master Data Key 
    key mandt, matnr, chargenr, batch, lagerort, werk, onhandqty1028 } 

// Joining transactional stock data directly in CDS for performance
join i_makt with result M (M.mandt = this.mandt AND M.vorka = 'Z_LGR') {
    @SemGroup: "Location Info" #! Grouped by Location Logic 
      onhandqty1028 as current_stock_qty,   // Current Stock Quantity
      
}

// Joining movement data for trend analysis (Historical Data)
join i_movt with result MV (MV.mandt = this.mandt AND MV.matnr = this.matnr) {  @SemGroup: "Movement Info" #! Grouped by Movement Logic 
      onhandqty1028 as in_qty,             // Input Qty
      
}

// Joining vendor data for supply chain visibility
join i_lfa1 with result VND (VND.mandt = this.mandt AND VND.lifnr = 'SUPPLIER_001') { @SemGroup: "Vendor Info" #! Grouped by Vendor Logic 
      name3 as supplier_name,              // Supplier Name
      
}

// Derived fields for optimization algorithms
  onhandqty1028 - in_qty + out_qty1047) / (@UnitFactor * this.onhandqty1028)) as stock_turnover_rate, @SemKey.name: 'STOCK_RATIO' #! Optimized Stock Ratio Key
  
}

@AbapCatalog.sqlViewOn: 'SAP_APPL' #
define view Z_mat_stock_details_extended as select from I_MARA { // Master Data Key 
    key mandt, matnr, chargenr, batch, lagerort, werk, onhandqty1028 } 

// Joining transactional stock data directly in CDS for performance
join i_makt with result M (M.mandt = this.mandt AND M.vorka = 'Z_LGR') {  @SemGroup: "Location Info" #! Grouped by Location Logic 
      onhandqty1028 as current_stock_qty,   // Current Stock Quantity
      
}

// Joining movement data for trend analysis (Historical Data)
join i_movt with result MV (MV.mandt = this.mandt AND MV.matnr = this.matnr) {  @SemGroup: "Movement Info" #! Grouped by Movement Logic 
      onhandqty1028 as in_qty,              // Input Qty
      
}

// Joining vendor data for supply chain visibility
join i_lfa1 with result VND (VND.mandt = this.mandt AND VND.lifnr = 'SUPPLIER_001') { @SemGroup: "Vendor Info" #! Grouped by Vendor Logic 
      name3 as supplier_name,                // Supplier Name
      
}

// Derived fields for optimization algorithms
  onhandqty1028 - in_qty + out_qty1047) / (@UnitFactor * this.onhandqty1028)) as stock_turnover_rate, @SemKey.name: 'STOCK_RATIO' #! Optimized Stock Ratio Key
  
}

// Adding annotations for Fiori Elements consumption
@EndUserText.segmentSize: medium 
  sum(stock_quantity_total) as total_available_stock, 
  
