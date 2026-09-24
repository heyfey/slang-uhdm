module top(input logic [31:0] a, output logic [1:0] we);
  if (1) begin : gb
    assign we = '{default: '1};
  end
endmodule
