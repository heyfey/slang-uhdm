// § tpUseSigBindsTpObj291
package pk; typedef logic [2:0] w_t; endpackage
interface ifc #(parameter type T = logic);
  T d;
  modport mp (input d);
endinterface
module sink (ifc.mp p, output logic o);
  assign o = ^p.d;
endmodule
module dut (input logic [2:0] a, output logic [1:0] o);
  ifc #(.T(pk::w_t)) i1 ();
  ifc i2 ();
  assign i1.d = a;
  assign i2.d = a[0];
  sink s1 (.p(i1), .o(o[0]));
  sink s2 (.p(i2), .o(o[1]));
endmodule
