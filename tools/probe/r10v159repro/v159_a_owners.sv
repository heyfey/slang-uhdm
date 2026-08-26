// v159 VERIFIER ARM A — OWNER positions the implementer's grid A did NOT cover.
// A package materialises a wildcard import; a CLASS METHOD folds reads of it in
// owner positions that other landed laws (psBoundPkgParamTs31, selFold, ips)
// also claim.  MEASUREMENT ONLY.
package vq159a_pkg;
  parameter int    VA_INT = 5;
  parameter        VA_UNT = 6;
  parameter bit [7:0] VA_BIT = 8'd7;
endpackage

package vp159a_pkg;
  import vq159a_pkg::*;

  class vc159a;
    int          r;
    int          k;
    logic [63:0] v;
    logic [63:0] w;
    int          arr [16];

    // A1 : part-select RANGE BOUND, bound arithmetic (one operation deep)
    function void a1_psbound();
      r = v[VA_INT-1:0];
    endfunction
    // A2 : part-select RANGE BOUND, TWO operations deep
    function void a2_psbound2();
      r = v[VA_INT-1+2:0];
    endfunction
    // A3 : part-select bound, PLAIN (no operation between)
    function void a3_psplain();
      r = v[VA_INT:0];
    endfunction
    // A4 : bit-select INDEX through an operation
    function void a4_selidx();
      r = v[VA_INT-1];
    endfunction
    // A5 : bit-select INDEX plain
    function void a5_selplain();
      r = v[VA_INT];
    endfunction
    // A6 : indexed part-select WIDTH and BASE
    function void a6_ips();
      w = v[VA_INT+:8];
      w = v[0+:VA_INT];
    endfunction
    // A7 : FOR-LOOP bound
    function void a7_forbound();
      for (int i = 0; i < VA_INT + 1; i++) r = i;
    endfunction
    // A8 : WHILE condition
    function void a8_while();
      while (k < VA_INT + 1) k++;
    endfunction
    // A9 : IF condition
    function void a9_if();
      if (k > VA_INT + 1) r = 1;
    endfunction
    // A10 : sys-func-call argument under an operation
    function void a10_sysarg();
      r = $clog2(VA_INT + 1);
    endfunction
    // A11 : operation whose operand is a sys-func-call of the param
    function void a11_sysop();
      r = $clog2(VA_INT) + 1;
    endfunction
    // A12 : array index of a local unpacked array, through an operation
    function void a12_arrsel();
      r = arr[VA_INT - 1];
    endfunction
    // A13 : DEFAULT ARGUMENT VALUE of a class method
    function void a13_defarg(int q = VA_INT + 1);
      r = q;
    endfunction
    // A14 : case item under an operation
    function void a14_case();
      case (k)
        VA_INT + 1: r = 1;
        default:    r = 0;
      endcase
    endfunction
    // A15 : nested operation depth 4
    function void a15_deep();
      r = ((VA_INT + 1) * 2 - 3) / 4;
    endfunction
    // A16 : assignment RHS with no operation (R1 control)
    function void a16_plain();
      r = VA_INT;
    endfunction
    // A17 : the untyped and the bit[7:0] faces in the same operand slot
    function void a17_faces();
      r = VA_UNT + 1;
      r = VA_BIT + 1;
    endfunction
    // A18 : concat and replication
    function void a18_cat();
      w = {VA_INT, VA_INT};
      w = {VA_INT{1'b1}};
    endfunction
    // A19 : QUALIFIED negative control in every risky slot
    function void a19_qual();
      r = vq159a_pkg::VA_INT + 1;
      r = v[vq159a_pkg::VA_INT-1:0];
    endfunction
  endclass
endpackage

module vm159a;
  import vp159a_pkg::*;
  vc159a h;
  initial begin
    h = new();
    h.a1_psbound();
  end
endmodule
