// § lpBoundOperandKeepsBase145v
module dut(input logic [31:0] a, input logic [31:0] b, output logic o);
  localparam int L = 4;
  localparam int H = 11;
  if (1) begin : g
    assign o = (a[H:L] >= b[H:L]) && (a[H:L] <= 8'hF0);
  end
endmodule
