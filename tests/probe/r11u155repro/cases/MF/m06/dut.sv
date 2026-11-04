// § modAggTfArgLastWriter155
module top(input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  function automatic logic [1:0] f (s_t op, s_t op2); return op.a; endfunction
  assign o = {2'b0, f(i, i)};
endmodule
