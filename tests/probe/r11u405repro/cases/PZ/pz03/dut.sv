// § impUnbasedReadIsLit405
package p;
  localparam none_lp = '0;
endpackage
module top; endmodule
module m import p::*; #(parameter w = 1) (input logic [3:0] i, output logic [3:0] o);
  assign o = i + none_lp;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
