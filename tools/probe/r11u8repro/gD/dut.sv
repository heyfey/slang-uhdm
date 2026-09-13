`define STR(__x) `"__x`"
`define D1P(__n) localparam string P1 = \
    `STR(__n);
`define D1E(__n) $error("%0s", \
         `STR(__n));
module top(input logic clk, input logic a);
  `D1P(ParamName)
  localparam string P0 = `STR(PlainName);
  always_ff @(posedge clk) begin
    if (!a) begin
      `D1E(ErrName)
    end
  end
endmodule
