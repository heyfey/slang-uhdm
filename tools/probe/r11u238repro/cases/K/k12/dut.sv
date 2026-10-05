// § cloneLoopVarClassPropArrayTs238
package p;
  class fac;
    int arr[4];
    string qs[$];
    int sink;
    extern function void run();
  endclass
  function void fac::run();
    for (int i = 0; i < 4; i++)
      foreach (this.arr[j]) sink = i + j + this.arr[j];
    foreach (this.qs[k])
      for (int m = 0; m < 2; m++) sink = k + m;
  endfunction
endpackage
package q;
  import p::*;
  function int g();
    fac f = new;
    f.run();
    return f.sink;
  endfunction
endpackage
module top;
  int x;
  initial x = q::g();
endmodule
