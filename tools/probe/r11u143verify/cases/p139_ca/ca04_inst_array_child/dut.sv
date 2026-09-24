// § caLhsDefNetUnlessOpRhs139
// case ca04: an assignment with a reference right-hand side inside the child of an array of instances
module sub(input logic a, output logic y); assign y = a; endmodule
module top(input logic [1:0] a, output logic [1:0] y);
  sub u[1:0](.a(a), .y(y));
endmodule
