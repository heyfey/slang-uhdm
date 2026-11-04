// § typedefDimNetDropsDims267
package hp;
  typedef logic [7:0] b_t;
endpackage
module leaf import hp::*; (input b_t [1:0] i, output b_t [1:0] o);
  assign o = ~i;
endmodule
module mid import hp::*; (input b_t [1:0] i, output b_t [1:0] o);
  leaf u_l(.i(i), .o(o));
endmodule
module top(input logic [15:0] i, output logic [15:0] o);
  mid u_m(.i(i), .o(o));
endmodule
