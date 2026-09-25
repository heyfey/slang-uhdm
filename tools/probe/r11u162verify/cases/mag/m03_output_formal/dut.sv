// § modAggTfArgLastWriter155
module top(input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  function automatic logic f (input logic [3:0] x, output s_t op); op = x; return 1'b1; endfunction
  s_t w; logic ok;
  always_comb ok = f(i, w);
  assign o = w;
endmodule
