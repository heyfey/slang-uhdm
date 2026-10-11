// § f3ParamCopyDeep284
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
program prg #(parameter q2::row_t UT = '0);
  initial $display(UT);
endprogram
module dut(output logic [5:0] o);
  prg #(.UT(6'h11)) p();
  assign o = 0;
endmodule
