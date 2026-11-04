// § impUnbasedReadIsLit405
package p;
  localparam z_lp = 'z;
  localparam a_lp = '0;
endpackage
module top import p::*; (input logic s, input logic [3:0] i, output logic [3:0] o);
  assign o = s ? i : (z_lp | a_lp);
endmodule
