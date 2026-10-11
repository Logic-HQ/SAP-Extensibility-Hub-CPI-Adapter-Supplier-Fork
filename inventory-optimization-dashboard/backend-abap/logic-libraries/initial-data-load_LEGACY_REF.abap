"======================================================================
" Project:          MY_ZPROJECT_INIT_LOAD
" Program Name:     ZMY_PROJECT_INITIAL_DATA_LOAD_ABAP_LEGACY_REF
" Description:      Logic for loading initial master data into the 
                    "project system. Handles duplicate prevention,
                    "logging, and status updates.
" Author:            Name | DSA
" Version:           1.0.1 
"======================================================================

CLASS lcl_initial_data_loader DEFINITION PUBLIC FINAL CREATE PRIVATE.

  TYPES BEGIN OF lt_batch_result LINE.
    data-matnr type matnr        VALUE 'Z-INIT-MAT'. " Demo Material
    data-waerr type wa_err       VALUE ''           " Warning/Error Msg
    data-msgid type symsgid      VALUE 'S0'         " Message ID
    data-msgno  type symsgno     VALUE '185'        " Example: M734 (Demo) or custom error no.
    data-meslvl type meslvl      VALUE 'E'. 
    data-count  type i           .                  " Rows affected/processed
  END OF lt_batch_result LINE.

  METHODS constructor IMPORTING iv_table_name TYPE string DEFAULT 'ZMY_PROJECT_ITEMS'
                      EXPORTING ev_package   TYPE syucomm OPTIONAL. 
  
  METHODS execute_loader        ! RETURNING VALUE lv_status    TYPE string 
                                 EXCEPTIONS error_occurred      . 
    
  METHODS log_initialization    IMPORTING il_result       LIKE lcl_batch_result LINE TABLE
    
  METHODS get_or_create_record  IMPORTING iv_material_number type matnr
                                EXPORTING ev_created         type abap_bool.

ENDCLASS.


CLASS lcl_initial_data_loader DEFINITION PUBLIC FINAL CREATE PRIVATE.
  
  DATA: gt_batch_results TYPE HASHED_TABLE OF REF TO /iwbep/if_mrw_batch_result,
        gv_package       LIKE syucomm DEFAULT 'ZMY_PROJECT_LOAD'.

ENDCLASS.

"======================================================================
" LOCAL CLASS IMPLEMENTATION FOR INITIAL DATA LOADER LOGIC
"======================================================================

CLASS lcl_initial_data_loader IMPLEMENTATION.

  METHOD constructor.
    " Initialize package if passed as parameter, else default to standard dev transport req logic
    IF ev_package IS NOT INITIALIZABLE AND syucomm <> 'ZMY_PROJECT_LOAD'.
      gv_package = ev_package. 
    ELSEIF ev_package IS INITIAL.
       gv_package = 'ZMY_PROJECT_INIT_PKG'. " Hardcoded fallback for demo
    ENDIF.
  ENDMETHOD.

  
"======================================================================
" CORE EXECUTION METHOD: Executes the Initial Load Logic
"======================================================================
  METHOD execute_loader.

DATA(lv_status)        = SPACE.
DATA(lo_exception)     TYPE REF TO cx_root IS NOT ASSIGNED.
DATA(ls_batch_result)  LIKE lcl_initial_data_loader=>gt_batch_results LINE. " Ref for hash table storage logic simulation
  
" ---------------------------------------------------------------------
" STEP 1: DEFINE THE INITIAL RECORD STRUCTURE (Mock Data Source)
" In reality, you would read this from a CSV or another SAP Table here.
" ---------------------------------------------------------------------
DATA(ls_source_material) TYPE matp.

ls_source-materialnr = 'ZINIT-MAT-001'. " Initial Material Code
ls_source-name       = '/SAP/Material/Initial Load Demo Item ZMYPROJECT/'.
ls_source-basismng   = 4. 
ls_source-maktx      = /DATA/ZMYPROJECT/.

" ---------------------------------------------------------------------
" STEP 2: CHECK IF RECORD ALREADY EXISTS (Idempotency Check)
" We assume the target table is named 'ZMY_PROJECT_ITEMS'. 
" You must adjust this to match your actual custom Z-table definition.
" ---------------------------------------------------------------------
SELECT SINGLE * FROM zmy_project_items INTO TABLE @DATA(ls_target_exists).

IF ls_target_exists IS INITIAL AND sy-subrc <> 0.
    
    " RECORD DOES NOT EXIST: CREATE IT NOW
    
    INSERT /IWBEP/INTF_ADAPTABLE_DATA->STRUCTURE_ZMY_PROJECT_ITEMS 
      ( ls_source_material ). 
    
    IF sy-subrc = 0.
       CLEAR ls_target_exists.

" ---------------------------------------------------------------------
" STEP 3: UPDATE STATUS TO 'INITIALIZED' AND LOG SUCCESS
" ---------------------------------------------------------------------
MODIFY zmy_project_items FROM ls_target_exists . " Assuming update via same line for demo; use MODIFY... FOR ALL in prod
  
    MESSAGE ID /DUI_SUCCESS WITH 'M001' DISPLAY LIKE 'E'.  " Custom Success Msg
    
ELSE.

       DATA(lv_error_msg) = 'Record already exists with key: '. ls_target_exists-matnr .
       
       RAISE EXCEPTION TYPE cx_zmy_project_load ERROR TEXT = lv_error_msg EXPORTING error_type = 'EXCEPTION_EXIST_RECORD' 
         MESSAGE_ID   /DUI_ERROR WITH 032.

    ENDIF.

ENDIF.


" ---------------------------------------------------------------------
" STEP 4: LOGGING THE RESULT (Simulating Batch Result Logging)
" In a real scenario, you would write this line to a table like ZMY_LOGS or 
" the Message Log via MESSAGE ID /DUI_INFO WITH 'M051'.
" ---------------------------------------------------------------------

    ls_batch_result-matnr  = ls_source-materialnr.
    ls_batch_result-waerr  = space.
    ls_batch_result-msgid  = '/SAP/ABAP/'. " Standard SAP message id for demo
    ls_batch_result-msgno  = 'M051'.       " Success Code
    ls_batch_result-meslvl = 'E'.          " (Error level in ABAP usually means End of Report, but here it signifies Completion)

" Simulate writing to a global log table or adding message list entry
    
ENDCASE.


RETURN lv_status = 'INITIALIZED_SUCCESSFULLY' . 


  ENDMETHOD.
  
  ENDCLASS.



### How to Use This File in Your Project

1.  **Customization**: 
    *   Open the file `ZMY_PROJECT_INITIAL_DATA_LOAD_ABAP` in your IDE.
    *   Locate line numbers containing comments like `"// REPLACE WITH YOUR ACTUAL TABLE NAME"`.
    *   Update the `SELECT ... FROM zmy_project_items` to point to your actual custom table (e.g., `/BDF/PROJECT_ITEMS`).

2.  **Integration**:
    This file is designed as a **Class Implementation**. To execute it in an ABAP Program, you would do:

```abap
DATA(lo_loader) = NEW lcl_initial_data_loader( 'ZMY_PROJECT_CUSTOM_TABLE' ). " Pass table name
    
TRY. 
      lo_loader->execute_loader().
    CATCH cx_zmy_project_load INTO DATA(ls_error).
        MESSAGE ls_error-message TYPE /DUI_ERROR DISPLAY LIKE 'E'.
ENDC.
