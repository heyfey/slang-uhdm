// § lpBoundOperandKeepsBase145v
module dut(input logic [31:0] a, output logic [31:0] o);
  localparam int L = 4;
  if (1) begin : g
    assign o = $unsigned(a[7:L]);
  end
endmodule
