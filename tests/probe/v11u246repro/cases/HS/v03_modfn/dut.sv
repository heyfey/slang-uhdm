// § hpFnStaticTrailScopeJoin246
module top;
  function int cnt();
    static int n;
    n++;
    return n;
  endfunction
  function int peek();
    return cnt.n;
  endfunction
  int r;
  int arr[4];
  initial begin
    r = peek();
    arr[cnt.n] = 1;
  end
endmodule
