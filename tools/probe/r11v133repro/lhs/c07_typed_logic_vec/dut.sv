// § impPaLhsDisjointClone133
package p; parameter logic [3:0] X = 4'd9; parameter bit signed [7:0] S = -8'sd3; endpackage
module m import p::*; #(parameter int Q = 1) (output logic [3:0] o, output logic [7:0] s);
  assign o = X + Q;
  assign s = S;
endmodule
module top(output logic [3:0] o, output logic [7:0] s); m u(.o(o), .s(s)); endmodule
