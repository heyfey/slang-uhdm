// § lpBoundOperandKeepsBase145v
module dut(input logic [31:0] a, output logic o);
  localparam int L = 4;
  localparam logic [3:0] B = 4'h5;
  if (1) begin : g
    assign o = a[7:L] == B;
  end
endmodule
