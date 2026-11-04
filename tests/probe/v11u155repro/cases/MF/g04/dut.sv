// § modAggTfArgLastWriter155
module top(input logic [3:0] i, output logic [3:0] o);
  typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
  function automatic logic [3:0] f (u_t op); return op.a; endfunction
  u_t w;
  assign w = i;
  assign o = f(w);
endmodule
