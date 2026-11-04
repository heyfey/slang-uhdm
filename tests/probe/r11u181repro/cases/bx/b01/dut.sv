// § bitSelParenIdxSpan181 — a parenthesized index of an rvalue bit-select in a concatenation (YosysRiscv's shape, no macro)
module top(input logic [31:0] din, output logic [31:0] dout);
  reg [31:0] b; integer i;
  always @* begin
    b = din;
    for (i = 0; i < 16; i = i+1)
      {b[(i*2)], b[(i*2+1)]} = {b[(i*2+1)], b[(i*2)]};
  end
  assign dout = b;
endmodule
