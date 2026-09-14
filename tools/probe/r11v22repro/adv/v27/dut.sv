module top(input logic [31:0] a, output logic signed [31:0] o);
  if (1) begin : gb
    assign o = (1) ? (32'sd7 - 32'sd9) : '0;
  end
endmodule
