// § cloneBodyCallBindsHomeTopTf446
package p;
  task automatic tk(input int v, output int o);
    o = v + 1;
  endtask
  task automatic wrap(input int v, output int o);
    tk(v, o);
  endtask
  function automatic int rec(int n);
    if (n <= 0) return 0;
    return rec(n - 1) + 1;
  endfunction
endpackage
package q;
  import p::*;
  function automatic int own(int b);
    int o;
    return rec(b);
  endfunction
endpackage
module top;
  import q::*;
  int o;
  initial o = own(2);
endmodule
