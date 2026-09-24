module top(input logic [31:0] a, input logic [4:0] s, output logic [31:0] o);
  if (1) begin : gb
    assign o = (1) ? 32'd5 : a[s +: 8];
  end
endmodule
