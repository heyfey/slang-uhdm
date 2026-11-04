package p1;
  function automatic int f(int n);
    int k = 0;
    do
      k++;
    while (k < n);
    return k;
  endfunction
endpackage
module top;
  import p1::*;
  int r;
  initial r = f(3);
endmodule
