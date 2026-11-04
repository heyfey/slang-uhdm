// § foreachArrayNamesTypedef417
package p;
  typedef logic [1:0] b;
  function automatic int f();
    int b[2];
    int n;
    foreach (b[i]) n += i;
    return n;
  endfunction
endpackage
module top;
  int n;
  initial n = p::f();
endmodule
