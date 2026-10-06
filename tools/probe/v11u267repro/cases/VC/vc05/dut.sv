// § typedefDimNetDropsDims267
package hp;
  typedef logic [7:0] b_t;
endpackage
module sha import hp::*; (input logic [31:0] i, output b_t [1:0] a, b);
  assign a = i[15:0];
  assign b = i[31:16];
endmodule
module top(input logic [31:0] i, output logic [15:0] a, output logic [15:0] b);
  sha u_s(.i(i), .a(a), .b(b));
endmodule
