// § modAggTfArgLastWriter155
module sub(input logic [3:0] i, output logic [1:0] o);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  function automatic logic [1:0] f (s_t op); return op.a; endfunction
  function automatic logic [1:0] g (s_t op); return op.b; endfunction
  assign o = f(i) ^ g(i);
endmodule
module top(input logic [3:0] i, output logic [1:0] o1, o2); sub a(i, o1); sub b(i, o2); endmodule
