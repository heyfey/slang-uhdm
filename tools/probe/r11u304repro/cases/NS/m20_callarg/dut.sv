// § hpOpIdxNestedSelByPath304
module top (input logic [3:0] w, input logic [1:0] j, output logic [7:0] o);
  typedef struct packed {logic [7:0] fld;} el_t;
  typedef struct packed {el_t [3:0] arr;} out_t;
  out_t t;
  el_t [3:0] ea;
  logic [1:0] k;
  logic [1:0] k2;
  function automatic logic [7:0] f(logic [7:0] x); return x; endfunction
  always_comb o = f(ea[k[0] + 1].fld);
endmodule
