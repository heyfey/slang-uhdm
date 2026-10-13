// § hpOpIdxNestedSelByPath304
package pk;
  typedef struct packed {logic [7:0] fld;} el_t;
  function automatic logic [7:0] rd(el_t [3:0] ea, logic [1:0] kk [2]);
    return ea[kk[0] + 1].fld;
  endfunction
endpackage
package q;
  import pk::*;
  function automatic logic [7:0] rd2(el_t [3:0] ea, logic [1:0] kk [2]);
    return rd(ea, kk);
  endfunction
endpackage
module top (input pk::el_t [3:0] ea, input logic [1:0] k [2], output logic [7:0] o);
  always_comb o = q::rd2(ea, k);
endmodule
