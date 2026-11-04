// § incDecBitSelWholeSpan181 § procLvIdxCallWholeSpan181 — a call as an inc/dec operand's select index and a compound assignment's
module top;
  int arr [8];
  int k;
  function automatic int f(int a); return a; endfunction
  initial begin
    arr[f(k)]++;
    arr[f(k)] += 2;
  end
endmodule
