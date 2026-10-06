// § typedefDimNetDropsDims267
package hp;
  typedef logic [3:0] w_t;
endpackage
program prg import hp::*; (input w_t [1:0] d);
endprogram
module top(input [7:0] d);
  prg u_p(.d(d));
endmodule
