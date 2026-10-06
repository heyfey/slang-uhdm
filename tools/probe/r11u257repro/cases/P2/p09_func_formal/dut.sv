// § implicitPortTsFirstDim257 (a function formal with a direction and two packed dimensions)
module m(input logic [7:0] i, output logic o);
  function automatic logic f(input [3:0][1:0] a); return a[0][0]; endfunction
  assign o = f(i); endmodule
module top; logic [7:0] i; logic o; m u(.i(i), .o(o)); endmodule
