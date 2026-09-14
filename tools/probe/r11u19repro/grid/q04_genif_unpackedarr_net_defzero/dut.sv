module top(input logic [31:0] a, output logic [31:0] arr[2]);
  if (1) begin : gb
    assign arr = '{default: '0};
  end
endmodule
