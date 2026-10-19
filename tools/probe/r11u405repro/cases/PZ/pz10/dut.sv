// § impUnbasedReadIsLit405
package p;
  localparam a_lp = '0;
  localparam c_lp = 'z;
endpackage
module sub import p::*; (input logic [3:0] i, output logic [3:0] o, output logic [3:0] r);
  assign o = i + a_lp;
  assign r = i | c_lp;
endmodule
module top (input logic [3:0] i, output logic [3:0] o, output logic [3:0] r);
  sub u(i, o, r);
endmodule
