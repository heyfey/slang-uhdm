// § typedefDimNetDropsDims267
package hp;
  typedef reg [7:0] r_t;
endpackage
module sha import hp::*; (input logic [15:0] i, output r_t [1:0] o);
  assign o = i;
endmodule
module top(input logic [15:0] i, output logic [15:0] o);
  sha u_s(.i(i), .o(o));
endmodule
