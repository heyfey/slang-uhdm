// § impUnbasedLitKept405
package p;
  localparam a_lp = '0;
  localparam b_lp = '1;
  localparam c_lp = 'x;
  localparam d_lp = 'z;
endpackage
module top; endmodule
module m import p::*; #(parameter w = 1) (input logic [3:0] i, output logic [3:0] o);
  assign o = i;
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
