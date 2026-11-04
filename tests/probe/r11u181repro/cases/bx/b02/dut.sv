// § bitSelParenIdxSpan181 — YosysRiscv's shape: macro-born parenthesized indices, both sides
`define IA(k, i) ((2 << (k))*((i)/(1 << (k))) + (i)%(1 << (k)))
`define IB(k, i) (`IA(k, i) + (1<<(k)))
module top(input logic [31:0] din, input logic [15:0] s, output logic [31:0] dout);
  reg [31:0] b; integer i;
  always @* begin
    b = din;
    for (i = 0; i < 16; i = i+1)
      if (s[i]) {b[`IA(4, i)], b[`IB(4, i)]} =
            {b[`IB(4, i)], b[`IA(4, i)]};
  end
  assign dout = b;
endmodule
