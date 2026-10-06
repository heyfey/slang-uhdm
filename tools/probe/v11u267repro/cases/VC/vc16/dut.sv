// § typedefDimNetDropsDims267
package hp;
  typedef logic [7:0] b_t;
endpackage
module sha import hp::*; (input b_t [1:0] i, output logic [15:0] o, output logic p);
  assign o = i;
  assign p = ^i;
endmodule
module top(input logic [15:0] i, output logic [15:0] o, output logic p);
  sha u_s(.i(i), .o(o), .p(p));
endmodule
