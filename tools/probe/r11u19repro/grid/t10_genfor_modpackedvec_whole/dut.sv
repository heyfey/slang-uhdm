module top(input logic [31:0] a, output logic [1:0] we);
  for (genvar i = 0; i < 1; i++) begin : gb
    assign we = '{default: '0};
  end
endmodule
