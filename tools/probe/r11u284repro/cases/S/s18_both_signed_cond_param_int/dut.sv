// § ternSgnLitFreshIntTs284
module dut #(parameter bit C = 1'b0) (output logic [31:0] o);
  localparam int K = 0;
  localparam int T = (K == 0) ? 3'sb101 : 3'sb001;
  assign o = 0;
endmodule
