// § f3ParamCopyDeep284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
interface ifc #(parameter q2::row_t UT = '0);
  logic [5:0] o;
  assign o = UT;
endinterface
module dut(output logic [5:0] o);
  ifc #(.UT(6'h11)) u();
  assign o = u.o;
endmodule
