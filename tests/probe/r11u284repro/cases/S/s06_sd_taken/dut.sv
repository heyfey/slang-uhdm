// § ternSgnLitFreshIntTs284
module dut #(parameter bit C = 1'b0) (output logic [31:0] o);
  localparam int T = C ? 12'sd0 : 12'sd5;
  assign o = 0;
endmodule
