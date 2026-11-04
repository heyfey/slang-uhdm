// § f3ParamCopyDeep284
`define RT q2::row_t
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module sub #(parameter `RT UT = '0) (output logic [5:0] o);
  assign o = UT;
endmodule
module dut (output logic [5:0] o);
  sub #(.UT(6'h21)) u (.o(o));
endmodule
