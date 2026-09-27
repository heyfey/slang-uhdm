// § procLvIdxCallWholeSpan181 — a call as a procedural lvalue select index (plain select, variable and constant argument)
module top;
  int arr [8];
  int k;
  function automatic int f(int a); return a; endfunction
  initial begin
    arr[f(k)] = 1;
    arr[f(1)] = 2;
    arr[f(k) + 1] = 3;
  end
endmodule
