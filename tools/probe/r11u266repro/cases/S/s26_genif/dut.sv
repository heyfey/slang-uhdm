// § sgnLitElabFreshIntTs266
module dut (input logic [63:0] x, output logic [63:0] o);
  localparam int P = 12'shFFF;
  if (1) begin : g
    assign o = P;
  end
endmodule
