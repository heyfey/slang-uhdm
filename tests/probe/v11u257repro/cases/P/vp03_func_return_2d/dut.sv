// § implicitPortTsFirstDim257 (a function return written as two packed dimensions)
module m(input logic [7:0] a, output logic [7:0] o);
  function [3:0][1:0] f(input [3:0][1:0] x); return x; endfunction
  assign o = f(a); endmodule
module top; logic [7:0] a, o; m u(.a(a), .o(o)); endmodule
