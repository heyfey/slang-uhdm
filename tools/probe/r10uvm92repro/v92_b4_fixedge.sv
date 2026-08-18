// r10uvm92 VERIFIER arm b4 — the edges of the VERIFIER'S OWN var_select fix.
`define DIM2 g2d[1][2]
package pk4;
  localparam int PARR[2][2] = '{'{1,2},'{3,4}};
  localparam int PLIN[2] = '{5,6};
  class el; int f; endclass
  class hold2; el bag[]; int q; int inner[2][2]; endclass

  class edger;
    hold2 hh;
    el    o;
    int   t, s;
    int   g2d[3][3];
    int   g3d[2][2][2];
    logic [15:0] lv[2];
    logic [3:0][7:0] p2;

    function void edges();
      // e01 package-parameter ARRAY as a var_select base (SITE 1 fold table)
      hh.bag[t + PARR[1][0]].f = 1;
      // e02 package-parameter LINEAR array (one level -> bit_select, EMPTY)
      hh.bag[t + PLIN[1]].f = 1;
      // e03 the 2-D select comes from a MACRO
      hh.bag[t + `DIM2].f = 1;
      // e04 var_select whose inner index is itself a var_select
      hh.bag[t + g2d[g3d[0][1][0]][2]].f = 1;
      // e05 var_select whose inner index is a bit_select (EMPTY inside)
      hh.bag[t + g2d[lv[0]][2]].f = 1;
      // e06 var_select nested three deep in operations
      hh.bag[(t + g2d[1][2]) * (s - g3d[0][1][1])].f = 1;
      // e07 var_select as the WHOLE index (not inside an operation) - control
      hh.bag[g2d[1][2]].f = 1;
      // e08 var_select in a replication body
      hh.bag[{2{g2d[1][2]}}].f = 1;
      // e09 var_select in a ternary condition
      hh.bag[g2d[1][2] ? t : s].f = 1;
      // e10 packed 2-D var_select with operation indices
      hh.bag[t + p2[t+1][s-1]].f = 1;
      // e11 var_select over a MEMBER-ACCESS base (must stay EMPTY)
      hh.bag[t + hh.inner[1][1]].f = 1;
      // e12 TRAIL lvalue with a var_select operand
      hh.bag[t - g2d[2][0]] = null;
      // e13 var_select inside inside{}
      hh.bag[t inside {g2d[1][1], 2}] = null;
      // e14 controls
      hh.bag[t + 1] = null;
      hh.bag[t + g2d[1][1]] = null;
    endfunction
  endclass
endpackage
