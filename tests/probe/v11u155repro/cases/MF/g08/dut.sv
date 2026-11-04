// § modAggTfArgLastWriter155
module top(input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  s_t w;
  function automatic logic [1:0] f (s_t op); return op.a; endfunction
  assign w = i;
  assign o = {f(w), w.b};
endmodule
