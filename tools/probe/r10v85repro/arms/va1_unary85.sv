// v85 adversarial arm A1 — every unary shape over the size(-1) BASED family
// and its negative controls, at several widths, both signedness.
package q85a_pkg;
  parameter int PW = 6;
endpackage
module va1_unary85 #(
  parameter int AddrW = 17,
  parameter int W = 8
) ();
  localparam int    LW = 8;
  localparam logic [31:0] LWL = 8;
  localparam bit signed [15:0] LWS = 8;

  // --- the head family: unary over a folded shift-minus with unsized based lhs
  localparam logic [AddrW-1:0] a01 = ~(('h1 << W) - 1'b1);
  localparam logic [AddrW-1:0] a02 = -(('h1 << W) - 1'b1);
  localparam logic [AddrW-1:0] a03 = !(('h1 << W) - 1'b1);
  localparam logic [AddrW-1:0] a04 = |(('h1 << W) - 1'b1);
  localparam logic [AddrW-1:0] a05 = &(('h1 << W) - 1'b1);
  localparam logic [AddrW-1:0] a06 = ^(('h1 << W) - 1'b1);
  localparam logic [AddrW-1:0] a07 = ~&(('h1 << W) - 1'b1);
  localparam logic [AddrW-1:0] a08 = ~|(('h1 << W) - 1'b1);
  localparam logic [AddrW-1:0] a09 = ~^(('h1 << W) - 1'b1);
  // nested
  localparam logic [AddrW-1:0] a10 = ~(~(('h1 << W) - 1'b1));
  localparam logic [AddrW-1:0] a11 = ~(-(('h1 << W) - 1'b1));

  // --- unary over a FOLDED ADD carrying an unsized based literal
  localparam logic [31:0] b01 = ~('h1 + W);
  localparam logic [31:0] b02 = ~('h1 + 'h2);
  localparam logic [31:0] b03 = -('h1 + W);
  localparam logic [31:0] b04 = ~('d5 + W);
  localparam logic [31:0] b05 = ~('o7 + W);
  localparam logic [31:0] b06 = ~('b1010 + W);

  // --- unary over a SIZED literal (negative control: must fold)
  localparam logic [31:0] c01 = ~(32'h1 << W);
  localparam logic [31:0] c02 = ~((32'h1 << W) - 1'b1);
  localparam logic [31:0] c03 = ~(1 << W);
  localparam logic [31:0] c04 = ~(8'hff);
  localparam logic [31:0] c05 = ~('hff);
  localparam logic [31:0] c06 = ~('h ff);
  localparam logic [31:0] c07 = ~W;
  localparam logic [31:0] c08 = ~LW;

  // --- the 'b0/'b1 spelling carve-out
  localparam logic [31:0] d01 = ~('b1 << W);
  localparam logic [31:0] d02 = ~('b0 << W);
  localparam logic [31:0] d03 = ~('B1 << W);
  localparam logic [31:0] d04 = ~('b11 << W);
  localparam logic [31:0] d05 = ~('sh1 << W);
  localparam logic [31:0] d06 = ~('sd1 << W);

  // --- unary over a $clog2 call
  localparam logic [31:0] e01 = ~($clog2(256));
  localparam logic [31:0] e02 = ~($clog2('h100));
  localparam logic [31:0] e03 = ~(('h1 << $clog2(256)) - 1'b1);

  // --- unary over a concatenation
  localparam logic [31:0] f01 = ~({4'hf, 4'h0});
  localparam logic [31:0] f02 = ~({'h1, 4'h0});
  localparam logic [31:0] f03 = |{'h1, 4'h0};

  // --- unary over a ternary
  localparam logic [31:0] g01 = ~((W > 4) ? 8'hf0 : 8'h0f);
  localparam logic [31:0] g02 = ~((W > 4) ? ('h1 << W) : 8'h0f);
  localparam logic [31:0] g03 = ~((W > 4) ? 8'hf0 : ('h1 << W));

  // --- widths
  localparam logic [7:0]  h08 = ~(('h1 << 3) - 1'b1);
  localparam logic [16:0] h17 = ~(('h1 << 3) - 1'b1);
  localparam logic [31:0] h32 = ~(('h1 << 3) - 1'b1);
  localparam logic [32:0] h33 = ~(('h1 << 3) - 1'b1);
  localparam logic [63:0] h64 = ~(('h1 << 3) - 1'b1);
  localparam logic [64:0] h65 = ~(('h1 << 3) - 1'b1);
  localparam int          hin = ~(('h1 << 3) - 1'b1);
  localparam bit signed [31:0] hbs = ~(('h1 << 3) - 1'b1);
  localparam                   him = ~(('h1 << 3) - 1'b1);
  localparam logic signed [31:0] hls = ~(('h1 << 3) - 1'b1);
endmodule
