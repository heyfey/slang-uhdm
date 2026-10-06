// § typedefDimNetDropsDims267
package hp;
  typedef logic [7:0] b_t;
endpackage
interface ifc import hp::*; (input b_t [1:0] d);
  wire b_t [1:0] w;
  assign w = d;
endinterface
module top(input logic [15:0] i, output logic [15:0] o);
  ifc u_i(.d(i));
  assign o = u_i.w;
endmodule
