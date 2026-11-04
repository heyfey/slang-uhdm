// § ternSgnLitFreshIntTs284
module dut #(parameter bit C = 1'b0) (output logic [31:0] o);
  localparam int T = C ? 6'so0 : 6'so17;
  assign o = 0;
endmodule
