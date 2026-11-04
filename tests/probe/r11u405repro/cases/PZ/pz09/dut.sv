// § impUnbasedReadIsLit405
package p;
  localparam a_lp = '0;
endpackage
module top (input logic [3:0] i, output logic [3:0] o);
  assign o = i + p::a_lp;
endmodule
