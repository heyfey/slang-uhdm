// § bitSelParenIdxSpan181 — a parenthesized index in a generate-for scope (genvar arithmetic) and a parameter initializer (control)
module top(input logic [7:0] din, output logic [3:0] y);
  localparam logic [7:0] C = 8'hA5;
  localparam logic P = C[(3)];
  for (genvar g = 0; g < 4; g++) begin : G
    assign y[g] = din[(g+1)] ^ P;
  end
endmodule
