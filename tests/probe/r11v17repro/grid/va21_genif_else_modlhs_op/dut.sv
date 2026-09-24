// The ELSE arm of a gen-if.
module top(input logic [31:0] a, output logic [31:0] o);
  parameter int P = 0;
  logic [31:0] mv;
  if (P == 1) begin : gt
    assign mv = a;
  end else begin : gf
    logic [31:0] src;
    assign src = a;
    assign mv = src | 32'd1;
  end
  assign o = mv;
endmodule
