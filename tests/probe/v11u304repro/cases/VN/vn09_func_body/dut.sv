// § hpOpIdxNestedSelByPath304
module top (input logic [1:0] k, output logic [7:0] o);
  typedef struct packed {logic [7:0] fld; logic [7:0] g;} el_t;
  el_t [3:0] ea;
  function automatic logic [7:0] rd(logic [1:0] kk);
    return ea[kk[0] + 1].fld;
  endfunction
  always_comb o = rd(k);
endmodule
