// § f3ParamCopyDeep284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module sub #(parameter q2::row_t UT = '0) (input q2::row_t i, output logic [5:0] o);
  assign o = UT ^ i;
endmodule
module dut (input logic [5:0] i, output logic [5:0] o);
  sub #(.UT(6'h21)) u (.i(i), .o(o));
endmodule
