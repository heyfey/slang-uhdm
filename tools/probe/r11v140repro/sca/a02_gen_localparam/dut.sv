// § sysArgUnaryWholeSpan140
module top(input logic [7:0] a, output int o);
  if (1) begin : g
    localparam int P = $bits(~a);
    assign o = P;
  end
endmodule
