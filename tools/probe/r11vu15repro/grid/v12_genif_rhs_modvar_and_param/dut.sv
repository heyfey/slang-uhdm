module top #(parameter int P = 3) (input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] loc;
    assign mv  = a;
    assign loc = mv + P;
  end
  assign o = mv;
endmodule
