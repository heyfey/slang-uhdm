// § ternSgnLitFreshIntTs284
module dut #(parameter bit C = 1'b0) (output logic [31:0] o);
  if (1) begin : g
    localparam int T = C ? 1'b0 : 1'sb1;
    assign o = T;
  end
endmodule
