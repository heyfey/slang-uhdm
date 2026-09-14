module top(input logic [31:0] a, output logic signed [3:0] we);
  if (1) begin : gb
    assign we = '{default: '0};
  end
endmodule
