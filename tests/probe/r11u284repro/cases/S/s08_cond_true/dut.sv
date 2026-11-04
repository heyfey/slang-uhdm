// § ternSgnLitFreshIntTs284
module dut #(parameter bit C = 1'b0) (output logic [31:0] o);
  localparam int T = !C ? 1'sb1 : 1'b0;
  assign o = 0;
endmodule
