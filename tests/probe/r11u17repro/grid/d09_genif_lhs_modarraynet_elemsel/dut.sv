module top(input logic [31:0] a, output logic [31:0] arr[2]);
  if (1) begin : gb
    assign arr[0] = '0;
    assign arr[1] = a;
  end
endmodule
