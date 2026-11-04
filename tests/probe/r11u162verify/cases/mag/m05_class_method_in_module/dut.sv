// § modAggTfArgLastWriter155
module top(input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  function automatic logic [1:0] f (s_t op); return op.a; endfunction
  class C; function logic [1:0] m (s_t op); return op.b; endfunction endclass
  assign o = {2'b0, f(i)};
endmodule
