// § sgnLitElabFreshIntTs266
module dut (output logic [31:0] o);
  if (1) begin : g
    localparam int P = 8'sh7F;
    assign o = P;
  end
endmodule
