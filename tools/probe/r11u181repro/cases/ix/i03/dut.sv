// § incDecBitSelWholeSpan181 — a bit-select inc/dec as a subexpression and in a for step
module top(input int i, output int y);
  int cnt [8];
  initial begin
    y = cnt[i]++;
    for (int k = 0; k < 4; cnt[k]++) k++;
  end
endmodule
