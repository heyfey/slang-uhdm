// § f3ParamCopyDeep284
package q2;
  typedef logic [3:0] ut_e;
  typedef ut_e [1:0] row_t;
endpackage
module sub #(parameter q2::row_t UT = '0) (output logic [7:0] o);
  assign o = UT;
endmodule
module dut (output logic [7:0] o);
  sub #(.UT(8'h21)) u (.o(o));
endmodule
