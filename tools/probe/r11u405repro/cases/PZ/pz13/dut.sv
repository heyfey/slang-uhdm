// § impUnbasedReadIsLit405
package p;
  localparam a_lp = '0;
endpackage
module top import p::*; (input clk, input logic [3:0] i, output logic [3:0] o);
  always_ff @(posedge clk) o <= i + a_lp;
endmodule
