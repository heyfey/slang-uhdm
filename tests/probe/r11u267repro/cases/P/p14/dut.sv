// § typedefDimNetDropsDims267
package hp;
  typedef logic [3:0] w_t;
endpackage
interface ifc import hp::*; (input w_t [1:0] digest);
endinterface
module top(input [7:0] d);
  ifc u_i(.digest(d));
endmodule
