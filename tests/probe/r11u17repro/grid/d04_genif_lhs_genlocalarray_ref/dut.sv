module top(input logic [31:0] a, input logic [31:0] q[2], output logic [31:0] o);
  if (1) begin : gb
    logic [31:0] ua[2];
    assign ua = q;
  end
  assign o = a;
endmodule
