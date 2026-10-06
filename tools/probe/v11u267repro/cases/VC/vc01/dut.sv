// § typedefDimNetDropsDims267
package hp;
  typedef logic [3:0][7:0] w2_t;
endpackage
module sha import hp::*; (input logic [63:0] i, output w2_t [1:0] o);
  assign o = i;
endmodule
module top(input logic [63:0] i, output logic [63:0] o);
  sha u_s(.i(i), .o(o));
endmodule
