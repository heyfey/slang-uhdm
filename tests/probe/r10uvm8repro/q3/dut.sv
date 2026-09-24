package pp;
  function automatic int pf1(input int a[4]);
    int s = 0;
    foreach (a[i]) s = s + a[i] + i;
    return s;
  endfunction
  class C;
    int cq[$];
    function int g1();
      int s = 0;
      foreach (cq[j]) s = s + j;
      return s;
    endfunction
  endclass
endpackage

module top;
  int arr[4];
  int r;
  function automatic int f1();
    int s = 0;
    foreach (arr[i]) s = s + arr[i] + i;
    return s;
  endfunction
  initial r = f1();
endmodule
