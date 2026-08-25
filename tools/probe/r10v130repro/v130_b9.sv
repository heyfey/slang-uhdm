// r10v130repro/v130_b9.sv — VERIFIER ARM b9: HOISTING CONTAINERS AND IMPORT
// SPELLINGS the pass's own grid did not reach — an INTERFACE, a PROGRAM, an
// EXPLICIT-ITEM import (`import p::c;`, not `::*`), and a module whose import
// sits INSIDE A GENERATE BLOCK.  MEASUREMENT ONLY.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
package pkCont130v;
  class cCont130v;
    int dynCont130v[];
    extern function void contRunner130v();
  endclass
  function void cCont130v::contRunner130v();
    int contSizePhi130v;
    contSizePhi130v = 3;
    dynCont130v = new[contSizePhi130v];
  endfunction
endpackage

// c01 an INTERFACE that imports the package at its own scope
interface ifCont130v;
  import pkCont130v::*;
  initial begin
    cCont130v hIf130v;
    hIf130v = new();
    hIf130v.contRunner130v();
  end
endinterface

// c02 a PROGRAM that imports the package at its own scope
program prgCont130v;
  import pkCont130v::*;
  initial begin
    cCont130v hPrg130v;
    hPrg130v = new();
    hPrg130v.contRunner130v();
  end
endprogram

// c03 a module with an EXPLICIT-ITEM import
module topItemCont130v;
  import pkCont130v::cCont130v;
  initial begin
    cCont130v hItem130v;
    hItem130v = new();
    hItem130v.contRunner130v();
  end
endmodule

// c04 a module whose import sits INSIDE A GENERATE BLOCK
module topGenCont130v;
  parameter int GEN130V = 1;
  if (GEN130V == 1) begin : gblkCont130v
    import pkCont130v::*;
    initial begin
      cCont130v hGen130v;
      hGen130v = new();
      hGen130v.contRunner130v();
    end
  end
endmodule

// c05 the CONTROL — a plain module with a wildcard import at its own scope
module topPlainCont130v;
  import pkCont130v::*;
  initial begin
    cCont130v hPlain130v;
    hPlain130v = new();
    hPlain130v.contRunner130v();
  end
endmodule
