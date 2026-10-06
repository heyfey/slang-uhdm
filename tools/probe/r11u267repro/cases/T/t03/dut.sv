// § typedefDimNetDropsDims267
package hp;
  typedef logic [3:0] w_t;
endpackage
interface ifc import hp::*; (input w_t [1:0] digest);
  modport mp (input digest);
endinterface
module c(ifc.mp p);
endmodule
module top(input [7:0] d);
  ifc u_i(.digest(d));
  c u_c(.p(u_i));
endmodule
