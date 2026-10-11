// § f3ParamCopyDeep284
package q2;
  typedef enum logic [1:0] { U0, U1, U2 } ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module sub #(parameter q2::row_t UT = '0) (output logic [5:0] o);
  assign o = UT;
endmodule
module dut(output logic [5:0] o);
  sub #(.UT({q2::U1, q2::U2, q2::U0})) u (.o(o));
endmodule
