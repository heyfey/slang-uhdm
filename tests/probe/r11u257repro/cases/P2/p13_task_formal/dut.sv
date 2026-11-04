// § implicitPortTsFirstDim257 (a task formal with a direction and two packed dimensions)
module m(input logic [7:0] i, output logic o);
  task automatic t(input [3:0][1:0] a, output logic r); r = a[0][0]; endtask
  always_comb t(i, o); endmodule
module top; logic [7:0] i; logic o; m u(.i(i), .o(o)); endmodule
