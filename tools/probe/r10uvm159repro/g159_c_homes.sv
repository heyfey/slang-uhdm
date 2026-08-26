// r10uvm159 GRID C — HOMES.  The same OPERATION-operand fold of an imported
// package parameter, reached from a class method / a package function / a
// module function / a module process / a generate-scope process, and from a
// module instantiated THREE times (so the DEF and every ELAB copy are scored
// separately).  MEASUREMENT ONLY.
package q159c_pkg;
  parameter int QC159 = 51;
endpackage

package p159c_pkg;
  import uvm_pkg::*;
  import q159c_pkg::*;
  `include "uvm_macros.svh"

  // C_PKGFUNC : a package FUNCTION, not a class method
  function automatic int c_pkgfunc159(int a);
    return a + UVM_SETINT + QC159;
  endfunction

  class c159c extends uvm_object;
    `uvm_object_utils(c159c)
    int r159;
    function new(string name = "c159c");
      super.new(name);
    endfunction
    // C_CLSFUNC
    function void c_clsfunc();
      r159 = UVM_SETINT + QC159;
    endfunction
  endclass
endpackage

module sub159c #(parameter int W159 = 1) (output int o159);
  import q159c_pkg::*;
  // C_MODFUNC
  function automatic int c_modfunc159(int a);
    return a + QC159;
  endfunction
  // C_MODPROC
  always_comb o159 = QC159 + W159;
  if (W159 > 0) begin : gen_c159
    // C_GENPROC
    int g159;
    always_comb g159 = QC159 + 1;
  end
endmodule

module m159c;
  import p159c_pkg::*;
  int o0159, o1159, o2159;
  c159c h159;
  sub159c #(.W159(1)) u0159 (.o159(o0159));
  sub159c #(.W159(2)) u1159 (.o159(o1159));
  sub159c #(.W159(3)) u2159 (.o159(o2159));
  initial begin
    h159 = new("h159");
    h159.c_clsfunc();
    o0159 = c_pkgfunc159(1);
  end
endmodule
