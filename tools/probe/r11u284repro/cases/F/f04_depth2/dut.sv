// § f3ParamCopyDeep284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module sub #(parameter q2::row_t UT = '0) (output logic [5:0] o);
  assign o = UT;
endmodule
module mid (output logic [5:0] o);
  sub #(.UT(6'h3)) u (.o(o));
endmodule
module dut (output logic [5:0] o);
  mid m (.o(o));
endmodule
