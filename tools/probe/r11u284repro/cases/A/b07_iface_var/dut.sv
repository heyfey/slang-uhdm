// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
interface ifc;
  pk::a_t v;
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.v = i;
  assign o = u.v;
endmodule
