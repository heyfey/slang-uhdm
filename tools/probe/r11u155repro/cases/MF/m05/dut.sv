// § modAggTfArgLastWriter155
module top(output logic [3:0] o);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  function automatic logic [1:0] f (s_t op); return op.a; endfunction
  localparam s_t P = '{a: 1, b: 2};
  assign o = {2'b0, f(P)};
endmodule
