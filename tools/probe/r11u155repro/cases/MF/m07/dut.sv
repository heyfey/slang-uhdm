// § modAggTfArgLastWriter155
module top(input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  task automatic t (input s_t op, output logic [1:0] r); r = op.a; endtask
  always_comb t(i, o[1:0]);
  assign o[3:2] = 0;
endmodule
