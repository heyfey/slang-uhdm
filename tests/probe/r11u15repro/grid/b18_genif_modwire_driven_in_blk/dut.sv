module top(input logic [31:0] a, output logic [31:0] o);
  wire [31:0] mw;
  if (1) begin : gb
    logic [31:0] loc;
    assign mw  = a;
    assign loc = mw;
  end
  assign o = mw;
endmodule
