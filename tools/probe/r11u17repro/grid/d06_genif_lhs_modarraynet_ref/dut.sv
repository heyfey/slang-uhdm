module top(input logic [31:0] a, input logic [31:0] q[2], output logic [31:0] arr[2]);
  if (1) begin : gb
    assign arr = q;
  end
endmodule
