// § hpOpIdxTernTrueKeepsIdxLoc304v
package pk;
  typedef struct packed {logic [7:0] fld;} el_t;
  function automatic logic [7:0] rd(el_t [3:0] ea, logic [1:0] kk [2], logic c);
    return ea[c ? kk[0] : kk[1]].fld;
  endfunction
endpackage
package q;
  import pk::*;
endpackage
module top (input pk::el_t [3:0] ea, input logic [1:0] k [2], input logic c, output logic [7:0] o);
  always_comb o = pk::rd(ea, k, c);
endmodule
