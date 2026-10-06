// § sgnLitElabFreshIntTs266
module dut #(parameter bit C = 1'b0) (output logic [63:0] o);
  localparam int P = C ? 1'sb0 : 1'sb1;
  assign o = P;
endmodule
