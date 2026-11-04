// § bitSelParenIdxSpan181 — a parenthesized index, plain rvalue and plain lvalue
module top(input logic [31:0] din, input int i, output logic y, output logic [31:0] q);
  always_comb begin
    y = din[(i+1)];
    q = '0;
    q[(i+1)] = 1'b1;
  end
endmodule
