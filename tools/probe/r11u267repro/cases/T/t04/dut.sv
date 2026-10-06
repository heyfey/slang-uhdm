// § typedefDimNetDropsDims267
package hp;
  typedef logic [3:0] w_t;
endpackage
module sha (input hp::w_t [1:0] a, output hp::w_t [1:0] b);
  assign b = a;
endmodule
module top(input [7:0] a, output [7:0] b);
  sha u_s(.a(a), .b(b));
endmodule
