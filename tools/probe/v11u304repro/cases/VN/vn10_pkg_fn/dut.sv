// § hpOpIdxNestedSelByPath304
package pk;
  typedef struct packed {logic [7:0] fld;} el_t;
  function automatic logic [7:0] rd(el_t [3:0] ea, logic [1:0] kk);
    return ea[kk[0] + 1].fld;
  endfunction
endpackage
module top (input pk::el_t [3:0] ea, input logic [1:0] k, output logic [7:0] o);
  always_comb o = pk::rd(ea, k);
endmodule
