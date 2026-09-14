module top(input logic [31:0] a, output logic [31:0] o);
  if (1) begin : gb
    assign o = (int'(3.7) == 4) ? 32'd7 : '0;
  end
endmodule
