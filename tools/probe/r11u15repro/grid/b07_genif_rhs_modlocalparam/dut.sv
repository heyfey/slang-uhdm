module top(input logic [31:0] a, output logic [31:0] o);
  localparam logic [31:0] LP = 32'd7;
  if (1) begin : gb
    logic [31:0] loc;
    assign loc = LP;
  end
  assign o = a;
endmodule
