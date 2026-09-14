module top(input logic [31:0] a, output logic o);
  if (1) begin : gb
    assign o = (1) ? 1'b1 : '0;
  end
endmodule
