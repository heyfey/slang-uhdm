// § lpBoundOperandKeepsBase145v
module dut(input logic [31:0] a, output logic o);
  localparam int L = 4;
  if (1) begin : g
    assign o = a[L+:4] == 4'd3;
  end
endmodule
