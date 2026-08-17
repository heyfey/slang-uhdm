// r10uvm81 VERIFIER arm B — LAW 1 IMMUNITY: every NON-package scope that owns a
// subroutine whose formal shadows a same-named container variable.  The patch's
// gate is `subHomeIsPkg81` + `pkgInst->UhdmType()==uhdmpackage`; every cell here
// must be BYTE-IDENTICAL between the pristine and the patched binary, and must
// equal golden.

// ---- $unit (compilation-unit) scope --------------------------------------
int unit_v;
function void uf_val(int unit_v);
  unit_v = unit_v + 1;                       // $unit fn, formal shadows $unit var
endfunction

// ---- INTERFACE scope ------------------------------------------------------
interface ifc92;
  int if_v;
  logic clk;
  function void if_fn(int if_v);
    if_v = if_v + 1;                         // interface fn
  endfunction
  task if_tk(int if_v);
    if_v = if_v + 2;
  endtask
endinterface

// ---- PROGRAM scope --------------------------------------------------------
program prg92;
  int pg_v;
  function void pg_fn(int pg_v);
    pg_v = pg_v + 1;                         // program fn
  endfunction
  initial pg_fn(1);
endprogram

// ---- MODULE scope (the load-bearing control, cell K's shape) --------------
module mod92;
  int md_v;
  int sink;
  function void md_fn(int md_v);
    sink = md_v;
  endfunction
  // a module-scope CLASS with an OUT-OF-BODY method — pkgScopeInst is not a pkg
  class mc92;
    int m_a;
    extern function void mset(int md_v);
  endclass
  function void mc92::mset(int md_v);
    m_a = md_v;
  endfunction
  initial begin
    md_fn(1);
  end
endmodule

// ---- a CHECKER's subroutine ----------------------------------------------
checker chk92(input logic c);
  int ck_v;
  function int ck_fn(int ck_v);
    return ck_v + 1;
  endfunction
endchecker

// ---- a package that IS a package, as the positive control -----------------
package pkg92;
  int ok_v;
  int sink;
  function void ok_fn(int ok_v);
    sink = ok_v;                             // MUST move to pkg92::ok_v
  endfunction
endpackage

// ---- a GENERATE-scope subroutine inside a module --------------------------
module mgen92;
  int gv_v;
  int sink;
  genvar g;
  generate
    for (g = 0; g < 2; g++) begin : blk
      int gv_v;
      function void gfn(int gv_v);
        sink = gv_v;
      endfunction
    end
  endgenerate
endmodule
