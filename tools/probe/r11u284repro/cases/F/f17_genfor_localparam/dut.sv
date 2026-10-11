// § f3ParamCopyDeep284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module sub #(parameter q2::row_t UT = '0) (output logic [5:0] o);
  assign o = UT;
endmodule
module dut (output logic [5:0] o [2]);
  for (genvar g = 0; g < 2; g++) begin : gg
    localparam q2::row_t UT = 6'h21 + g;
    sub #(.UT(UT)) u (.o(o[g]));
  end
endmodule
