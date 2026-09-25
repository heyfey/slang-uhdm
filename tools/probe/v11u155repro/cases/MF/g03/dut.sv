// § modAggTfArgLastWriter155
module top(input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  function automatic logic [1:0] f (s_t op); return op.a; endfunction
  task automatic t (input s_t op, output logic [1:0] r); r = op.b; endtask
  always_comb t(i, o[3:2]);
  assign o[1:0] = f(i);
endmodule
