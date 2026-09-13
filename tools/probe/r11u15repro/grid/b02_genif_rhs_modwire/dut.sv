module top(input logic [31:0] a, output logic [31:0] o);
  wire [31:0] mw;
  assign mw = a;
  if (1) begin : gb
    logic [31:0] loc;
    assign loc = mw;
  end
  assign o = mw;
endmodule
