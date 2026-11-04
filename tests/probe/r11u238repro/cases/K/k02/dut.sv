// § cloneForIncBindsHomeVar238
package p;
  function int f(int n);
    int acc = 0;
    for (int i = 0, int j = 1; i < n; i++, j += 2) acc += j;
    for (integer m = n; m > 0; m = m - 1) acc--;
    for (int r = 0; r < n; ++r) acc++;
    return acc;
  endfunction
endpackage
package q;
  import p::*;
  function int g(int n);
    return f(n);
  endfunction
endpackage
module top;
  import q::*;
  int x;
  initial x = g(3);
endmodule
