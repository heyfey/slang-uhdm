// § impPaLhsDisjointClone133
package p; localparam int X = 4; localparam logic [7:0] Y = 8'hA5; endpackage
module m import p::*; #(parameter int Q = X) (output int o, output logic [7:0] y);
  assign o = Q;
  assign y = Y;
endmodule
module top(output int o, output logic [7:0] y); m u(.o(o), .y(y)); endmodule
