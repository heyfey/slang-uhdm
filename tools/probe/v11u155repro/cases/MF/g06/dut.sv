// § modAggTfArgLastWriter155
module top(input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  function automatic logic [1:0] f (s_t op = '0); return op.a; endfunction
  assign o = {f(i), f()};
endmodule
