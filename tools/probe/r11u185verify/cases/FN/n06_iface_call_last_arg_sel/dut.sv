// § refFullNameThroughNamedExpr175
interface ifc;
  function automatic int h(int a, int b); return a + b; endfunction
endinterface
module top;
  ifc u();
  int arr [4];
  function automatic int f(int k);
    int s;
    s = u.h(k, arr[k]);
    s += u.h(arr[k + 1], k);
    return s;
  endfunction
  int r; initial r = f(1);
endmodule
