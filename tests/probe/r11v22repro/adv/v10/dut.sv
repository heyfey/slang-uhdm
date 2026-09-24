module top #(parameter int W = 33)(input logic [31:0] a, output logic [31:0] o);
  if (1) begin : gb
    assign o = ($clog2(W) == 6) ? 32'd7 : '0;
  end
endmodule
