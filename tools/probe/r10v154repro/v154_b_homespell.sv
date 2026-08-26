// r10v154 arm B — THE CONTROL THE FIX MUST NOT BREAK.
//
// Every home OTHER than `$unit` that has a single listing (module, class,
// parameterized class, interface) takes the DEF spelling: golden keeps the
// WRITTEN digits, `-0` and `-007` included.  The package home has TWO
// listings and shows both spellings, def then elaborated.  If the fix had
// been "always fold", these cells would all have gone AWAY-GOLDEN.
//
// Golden, measured:
//   package  BOX_ZERO/BOX_LEAD : def `-0` / `-007` , elab `0` / `-7`
//   module   MOD_ZERO/MOD_LEAD : `-0` / `-007`
//   class    CLS_ZERO/CLS_LEAD : `-0` / `-007`
//   iface    IFC_ZERO/IFC_LEAD : `-0` / `-007`
package boxpkg;
  typedef enum bit [31:0] { BOX_ZERO = -0, BOX_TAIL = 4 } box_zero_t;
  typedef enum int        { BOX_LEAD = -007, BOX_TAILB = 4 } box_lead_t;
  class GearHolder #(int SPAN = 8);
    typedef enum byte { CLS_ZERO = -0, CLS_TAIL = 4 } cls_zero_t;
    typedef enum int  { CLS_LEAD = -007, CLS_TAILB = 4 } cls_lead_t;
  endclass
endpackage
module rider_mod;
  typedef enum bit [31:0] { MOD_ZERO = -0, MOD_TAIL = 4 } mod_zero_t;
  typedef enum int        { MOD_LEAD = -007, MOD_TAILB = 4 } mod_lead_t;
  mod_zero_t mz; mod_lead_t ml;
  initial begin mz = MOD_ZERO; ml = MOD_LEAD; end
endmodule
interface span_ifc;
  typedef enum byte { IFC_ZERO = -0, IFC_TAIL = 4 } ifc_zero_t;
  typedef enum int  { IFC_LEAD = -007, IFC_TAILB = 4 } ifc_lead_t;
  ifc_zero_t iz; ifc_lead_t il;
endinterface
module dut_homespell;
  import boxpkg::*;
  box_zero_t bz; box_lead_t bl; GearHolder #(16) gh;
  rider_mod u_rider (); span_ifc u_span ();
  initial begin bz = BOX_ZERO; bl = BOX_LEAD; gh = new(); end
endmodule
