// § f3ParamCopyDeep284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module dut(output logic [5:0] o);
  if (1) begin : g
    localparam q2::row_t UT = 6'h21;
    assign o = UT;
  end
endmodule
