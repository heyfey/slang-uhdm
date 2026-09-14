module top(input logic [31:0] a, output logic [31:0] o);
  if (1) begin : gb
    if (1) begin : gc
      if (1) begin : gd
        assign o = (1) ? 32'd3 : '0;
      end
    end
  end
endmodule
