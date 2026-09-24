module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : go
    if (1) begin : gi
      logic [31:0] src;
      assign src = a;
      assign mv = src | 32'd1;
    end
  end
  assign o = mv;
endmodule
