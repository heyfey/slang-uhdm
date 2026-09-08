// r10uvm221 arm a4_corpus — THE CORPUS SHAPE, reproduced.
//
// MiniAmiq's holder is `interface_inst work@svaunit_vpi_interface`: an
// UNINSTANTIATED interface that carries `export "DPI-C"` items far above their
// definitions (§ dpiExportListedAtExportItem216) and whose head cell is
//     svaunit_vpi_interface.sv:155:20   `return SVAUNIT_START;`
// inside `function svaunit_concurrent_assertion_state_type
// get_state_from_reason(int a_reason)` — a RETURN whose value is a constant of
// the function's OWN return enum, declared in an imported package.
//
// This arm rebuilds exactly that: the enum in a package, the interface
// importing it, the function typed by the enum, the returns in an
// if/else-if chain nested inside an `inside`-guarded begin block, DPI exports
// beside them, and (to check § uninstIfaceForeachHdrUnresolved220 for
// collision) a `foreach` header in the same body.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

package sv221_pkg;
   typedef enum int {
      SV_IDLE          = 0,
      SV_START         = 1,
      SV_SUCCESS       = 2,
      SV_FAILURE       = 3,
      SV_STEP_SUCCESS  = 4,
      SV_STEP_FAILURE  = 5
   } sv221_state_t;

   class sv221_info;
      int idx;
   endclass
endpackage

interface sv221_if;                                   // NEVER INSTANTIATED
   import sv221_pkg::*;

   sv221_info a_lof [];
   sv221_state_t states [0:5];

   export "DPI-C" function set_name221;
   export "DPI-C" task    kick221;

   function sv221_state_t get_state221(int a_reason);  // the corpus function
      if (a_reason inside {1, 2, 3, 4, 5}) begin
         if (a_reason == 1) begin
            return SV_START;                           // d01 THE HEAD'S SHAPE
         end
         else if (a_reason == 2) begin
            return SV_SUCCESS;                         // d02
         end
         if (a_reason == 3) begin
            return SV_FAILURE;                         // d03
         end
         else if (a_reason == 4) begin
            return SV_STEP_SUCCESS;                    // d04
         end
         else if (a_reason == 5) begin
            return SV_STEP_FAILURE;                    // d05
         end
      end
      return SV_IDLE;                                  // d06
   endfunction

   function void set_name221(input int a_v);           // a DPI-EXPORTED function
      static sv221_state_t crt = get_state221(a_v);
      if (crt == SV_START) begin                       // d07 condition, window
         states[0] = SV_SUCCESS;                       // d08 select LHS, const RHS
      end
      // THE CORPUS'S SECOND SHAPE — svaunit_vpi_interface.sv:206, an `inside`
      // SET whose six members are all enum constants, nested two `if`s deep
      // inside a `foreach` body.
      if (crt inside {SV_SUCCESS, SV_FAILURE, SV_STEP_SUCCESS}) begin
         states[2] = SV_IDLE;                          // d11/d12/d13 inside-set
      end
   endfunction

   task kick221(input int a_v);                        // a DPI-EXPORTED task
      states[1] = SV_FAILURE;                          // d09
   endtask

   function int count221();                            // the § 220 collision check
      int n;
      n = 0;
      foreach (a_lof[index]) begin
         n = n + 1;
      end
      foreach (states[k]) begin
         if (states[k] == SV_IDLE) n = n + 1;          // d10 enum const under a foreach
      end
      return n;
   endfunction
endinterface
