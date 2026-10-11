// § f3ParamCopyDeep284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module sub #(parameter q2::row_t A = '0, parameter q2::row_t B = 6'h1) (output logic [5:0] o);
  assign o = A ^ B;
endmodule
module dut (output logic [5:0] o);
  sub #(.A(6'h21)) u (.o(o));
endmodule
