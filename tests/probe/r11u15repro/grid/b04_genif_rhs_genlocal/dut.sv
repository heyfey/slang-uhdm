module top(input logic [31:0] a, output logic [31:0] o);
  if (1) begin : gb
    logic [31:0] src;
    logic [31:0] loc;
    assign src = a;
    assign loc = src;
  end
  assign o = a;
endmodule
