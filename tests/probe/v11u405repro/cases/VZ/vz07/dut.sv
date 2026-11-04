// § impUnbasedReadIsLit405
package p;
  localparam b_lp = '1;
endpackage
module top import p::*; (input clk, input logic [3:0] i, output logic [3:0] o);
  always_ff @(posedge clk) if (i != b_lp) o <= i - b_lp;
endmodule
