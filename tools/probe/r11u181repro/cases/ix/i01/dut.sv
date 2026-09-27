// § incDecBitSelWholeSpan181 — a bit-select inc/dec operand in a module initial (plain, parenthesized, operation index)
module top(input int i);
  int cnt [8];
  initial begin
    cnt[i]++;
    cnt[(i)]--;
    ++cnt[i+1];
    --cnt[(i*2)];
  end
endmodule
