// § typedefDimNetDropsDims267
package hp;
  typedef logic [7:0] b_t;
endpackage
module sha import hp::*; (input logic [15:0] i, output b_t [1:0] o [2]);
  assign o[0] = i;
  assign o[1] = ~i;
endmodule
module top(input logic [15:0] i, output logic [15:0] o0, output logic [15:0] o1);
  logic [15:0] w [2];
  sha u_s(.i(i), .o(w));
  assign o0 = w[0];
  assign o1 = w[1];
endmodule
