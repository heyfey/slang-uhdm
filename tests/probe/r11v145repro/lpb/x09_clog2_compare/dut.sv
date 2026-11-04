// § lpBoundOperandKeepsBase145v
module dut #(parameter int BW = 32) (input logic [7:0] a, output logic o);
  localparam int L = $clog2(BW) - 3;
  if (1) begin : g
    assign o = a[7:L] == 6'd3;
  end
endmodule
