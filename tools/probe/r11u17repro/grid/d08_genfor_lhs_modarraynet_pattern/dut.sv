module top(input logic [31:0] a, output logic [31:0] arr[2]);
  for (genvar i = 0; i < 1; i++) begin : gb
    assign arr = '{default: '0};
  end
endmodule
