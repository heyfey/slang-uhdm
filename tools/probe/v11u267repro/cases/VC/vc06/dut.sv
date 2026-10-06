// § typedefDimNetDropsDims267
package hp;
  typedef logic [0:7] b_t;
endpackage
module sha import hp::*; #(parameter int N = 3) (input logic [8*N-1:0] i, output b_t [N-1:0] o);
  assign o = i;
endmodule
module top(input logic [23:0] i, output logic [23:0] o, output logic [15:0] o2);
  sha u_s(.i(i), .o(o));
  sha #(.N(2)) u_s2(.i(i[15:0]), .o(o2));
endmodule
