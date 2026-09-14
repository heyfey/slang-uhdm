module top #(parameter int K = -1)(input logic [31:0] a, output logic [31:0] o);
  if (1) begin : gb
    assign o = (K < 32'd0) ? 32'd7 : '0;
  end
endmodule
