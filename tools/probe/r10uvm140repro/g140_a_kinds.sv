// r10uvm140 arm A — TYPEDEF KINDS x base/alias/chain on a FUNCTION RETURN.
// The law under test: when a function's return type NAMES a typedef, the
// return var's ref_typespec must bind THAT typedef's own listing object,
// not some other alias sharing the same canonical type.
// Names deliberately NOT parallel (no a_t/b_t/c_t): every cell is named for
// what it is, in mixed case and with varied numbering, so an arm agreeing
// with golden is agreeing for a reason.
package Chrome_pkg;

  typedef enum { ZINC = 3, COBALT = 12, Nickel = 28 } metalKind;
  typedef metalKind    MetalKind_e;        // backward-compat style alias
  typedef MetalKind_e  metal_kind_t;       // 2-deep chain
  typedef metalKind    OreKind_e;          // a SECOND alias of the same base

  typedef struct packed { logic [5:0] mass; logic [1:0] charge; } ionRec;
  typedef ionRec       IonRec_s;
  typedef IonRec_s     ion_record_t;

  typedef union packed { logic [7:0] raw; logic [7:0] cooked; } sampleWord;
  typedef sampleWord   SampleWord_u;

  typedef logic [11:0] rulerBits;
  typedef rulerBits    RulerBits_v;

  class Assay;
    // --- the BASE returns (must-not-move controls) ---
    function metalKind  readBaseMetal();   return ZINC;            endfunction
    function ionRec     readBaseIon();     ionRec r;   return r;   endfunction
    function sampleWord readBaseSample();  sampleWord r; return r; endfunction
    function rulerBits  readBaseRuler();   return '0;              endfunction
    // --- the ALIAS returns (the law) ---
    function MetalKind_e  readAliasMetal();  return COBALT;        endfunction
    function OreKind_e    readOreMetal();    return Nickel;        endfunction
    function metal_kind_t readChainMetal();  return ZINC;          endfunction
    function IonRec_s     readAliasIon();    IonRec_s r; return r; endfunction
    function ion_record_t readChainIon();    ion_record_t r; return r; endfunction
    function SampleWord_u readAliasSample(); SampleWord_u r; return r; endfunction
    function RulerBits_v  readAliasRuler();  return '0;            endfunction
    // --- the ARGUMENT twin (already golden today; a control) ---
    function void takeAliasMetal(MetalKind_e v); endfunction
  endclass

  // package-scope (non-class) functions
  function OreKind_e pkgOre();   return ZINC;   endfunction
  function metalKind pkgMetal(); return COBALT; endfunction
  function IonRec_s  pkgIon();   IonRec_s r; return r; endfunction

endpackage

module Furnace;
  import Chrome_pkg::*;
  Assay probe1;
  MetalKind_e seen;
  initial begin
    probe1 = new();
    seen = probe1.readAliasMetal();
  end
endmodule
