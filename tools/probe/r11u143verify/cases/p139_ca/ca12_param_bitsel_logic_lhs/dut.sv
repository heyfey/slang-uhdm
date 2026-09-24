// § caLhsDefNetUnlessOpRhs139
// case ca12: a bit-select of a module parameter onto a body logic variable
module top #(parameter logic [3:0] P = 4'b1010) (output logic y);
  logic t;
  assign t = P[1];
  assign y = t;
endmodule
