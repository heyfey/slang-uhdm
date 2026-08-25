// v85 adversarial arm A6 — the UNBASED family (r10oth2's own law) must be
// untouched, including the shapes the patch changed the `default:` /
// depth / pattern-conditional refusals for.
module va6_unbased85 #(parameter int W = 4) ();
  localparam logic [31:0] z01 = ~('1);
  localparam logic [31:0] z02 = ~('0);
  localparam logic [31:0] z03 = ~('x);
  localparam logic [31:0] z04 = ('1 << W);
  localparam logic [31:0] z05 = ~(('1 << W) - 1'b1);
  localparam logic [31:0] z06 = {'x, 1'b1};
  localparam logic [31:0] z07 = ((W > 2) ? '0 : '1) << 1;
  localparam logic [31:0] z08 = {4{'1}};
  localparam logic [31:0] z09 = ~('1 + W);
  localparam logic [31:0] z10 = ~{'1, 'h1};
  localparam logic [31:0] z11 = ~(('h1 << W) - '1);
  // assignment-pattern over unsized literals (the ParamArrayUnsizedPattern shape)
  localparam logic [3:0] z12 [0:1] = '{default: '1};
  localparam logic [3:0] z13 [0:1] = '{'1, '1};
  localparam logic [3:0] z14 [0:1] = '{'h1, 'h1};
  localparam logic [3:0] z15 [0:1] = '{default: 'h1};
endmodule
