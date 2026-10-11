@AbapCatalog.sqlViewOn: 'SAP_APPL' #
define view Z_inv_opt_header as select from i_makt {  // MANDT, VORW (Storage Loc Grp)
    key mandt,          @SemKey.name: 'MANDANT',       @(Unique: true),
      vorka,            @SemKey.name: 'LAGRGRUPPE'     #! The Storage Location Group Key
      
    // KPI Aggregations Computed in DB (No Frontend Load)
  , @EndUserText.segmentSize: medium 
    sum(stock_quantity_total) as total_available_stock,
    
  }, at [mandt, vorka]; 

// Additional HANA Calculated Columns for Optimization Logic
  count(distinct material_master_key) as unique_material_count,
  
}

@AbapCatalog.sqlViewOn: 'SAP_APPL' #
define view Z_inv_opt_header_extended as select from I_MAKT {  // MANDT, VORW (Storage Loc Grp)
    key mandt,          @SemKey.name: 'MANDANT',       @(Unique: true),
      vorka,            @SemKey.name: 'LAGRGRUPPE'     #! The Storage Location Group Key
      
  // KPI Aggregations Computed in DB (No Frontend Load)
    sum(stock_quantity_total) as total_available_stock,

}, at [mandt, vorka]; 

// Additional HANA Calculated Columns for Optimization Logic
  count(distinct material_master_key) as unique_material_count,

}
