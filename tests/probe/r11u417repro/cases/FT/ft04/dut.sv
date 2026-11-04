// § foreachArrayNamesTypedef417
package p;
  typedef logic [7:0] b;
  function automatic int f(int m[$]);
    int b[$];
    int n;
    b = m;
    foreach (b[idx]) n += idx;
    return n;
  endfunction
endpackage
module top;
endmodule
