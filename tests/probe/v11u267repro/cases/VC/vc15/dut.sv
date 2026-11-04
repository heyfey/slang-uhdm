// § typedefDimNetDropsDims267
package hp;
  typedef logic [7:0] b_t;
endpackage
module sha (i, o);
  import hp::*;
  input logic [15:0] i;
  output b_t [1:0] o;
  assign o = i;
endmodule
module top(input logic [15:0] i, output logic [15:0] o);
  sha u_s(i, o);
endmodule
