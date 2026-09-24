module top(input logic [31:0] a, output logic [31:0] arr[2]);
  if (1) begin : gb
    logic [31:0] src;
    assign src = a;
    assign arr = '{src, src};
  end
endmodule
