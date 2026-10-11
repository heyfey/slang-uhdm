// § ternSgnLitFreshIntTs284
module dut #(parameter bit C = 1'b0) (output logic [31:0] o);
  localparam logic signed [31:0] T = C ? 1'sb0 : 1'sb1;
  assign o = 0;
endmodule
