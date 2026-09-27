// § incDecBitSelWholeSpan181 § bitSelParenIdxSpan181 — a parenthesized cast index, a system call argument, an inc/dec operand
module top(input logic [7:0] din, input logic [2:0] i, output int cnt [8]);
  initial begin
    $display("%b", din[(int'(i))]);
    cnt[(i)]++;
    cnt[(i+1)] += 1;
  end
endmodule
