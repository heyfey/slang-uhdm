module top(input logic [63:0] a, output logic [63:0] o);
  if (1) begin : gb
    assign o = (1) ? '1 : '0;
  end
endmodule
