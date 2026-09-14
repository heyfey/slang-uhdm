module top(input logic [31:0] a, output logic [1:0] o);
  if (1) begin : gb
    wire [1:0] w = '{default: '0};
    assign o = w;
  end
endmodule
