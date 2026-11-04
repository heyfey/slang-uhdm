// § modAggTfArgLastWriter155
module top(input logic [3:0] i, output logic [3:0] o);
  typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
  task automatic t1 (input u_t op, output logic [3:0] r); r = op.a; endtask
  task automatic t2 (input u_t op, output logic [3:0] r); r = op.b; endtask
  always_comb t2(i, o);
endmodule
