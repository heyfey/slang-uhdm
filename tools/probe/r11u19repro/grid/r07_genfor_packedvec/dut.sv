module top(input logic [31:0] a, output logic [1:0] we[2]);
  for (genvar i = 0; i < 2; i++) begin : gb
    assign we[i] = '{default: '0};
  end
endmodule
