// r10v81 arm v6 — THE VALUE EDGES of the bare-decimal producer: zero, many
// leading zeros, spacing + a comment inside the actual, a 16-bit-wide value,
// and a value that OVERFLOWS slang's 32-bit unsized literal type (slang
// truncates it to -1, which the shipped gate's re-evaluation must REFUSE).
// MEASUREMENT ONLY.
module leafv6 (input logic ib, output logic o);
  assign o = ib;
endmodule
module midv6 #(
  parameter int unsigned Z0 = 1,   // overridden with 0
  parameter int unsigned ZL = 1,   // overridden with 0000002
  parameter int unsigned SP = 1,   // overridden with spacing + a comment
  parameter int unsigned BG = 1    // overridden with 65535
) (
  input  logic [15:0]    w,
  input  logic [65535:0] wbig,
  output logic [15:0]    y
);
  leafv6 uZ0 (.ib(w[Z0]),    .o(y[0]));
  leafv6 uZL (.ib(w[ZL]),    .o(y[1]));
  leafv6 uSP (.ib(w[SP]),    .o(y[2]));
  leafv6 uBG (.ib(wbig[BG]), .o(y[3]));
endmodule
module topv6 (input logic [15:0] w, input logic [65535:0] wbig,
              output logic [15:0] y);
  midv6 #(.Z0(0), .ZL(0000002), .SP(  3 /*three*/ ), .BG(65535)) i0 (.w(w), .wbig(wbig), .y(y));
endmodule
