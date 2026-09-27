// § bitSelParenIdxSpan181 — break hunt: a macro-born parenthesized index from an included file, a parenthesized index in a generate continuous assignment and a parameter initializer, a nested parenthesized select
`include "a03_inc.svh"
module top(input logic [31:0] din, input int i, output logic y, output logic [3:0] z, output logic w);
  localparam logic [7:0] C = 8'hA5;
  localparam logic P = C[(3)];
  assign y = din[`IDX(i)];
  for (genvar g = 0; g < 4; g++) begin : G
    assign z[g] = din[(g+1)];
  end
  assign w = din[(din[(i)])] ^ P;
endmodule
