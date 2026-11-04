// § ternSgnLitFreshIntTs284
module dut #(parameter bit C = 1'b0) (output logic [31:0] o);
  localparam int T = 1'b1 ? 4'sb1010 : 4'b0;
  assign o = 0;
endmodule
