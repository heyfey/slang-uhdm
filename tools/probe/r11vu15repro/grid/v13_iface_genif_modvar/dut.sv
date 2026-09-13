interface itf(input logic [31:0] a);
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] loc;
    assign mv  = a;
    assign loc = mv;
  end
endinterface
module top(input logic [31:0] a, output logic [31:0] o);
  itf i0(.a(a));
  assign o = i0.mv;
endmodule
