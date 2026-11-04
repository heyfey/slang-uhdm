// § cloneForIncBindsHomeVar238
package p;
  function automatic void t(output int o);
    o = 0;
    for (int i = 0; i < 4; i++) o += i;
  endfunction
  function int f();
    int i;
    for (i = 0; i < 4; i++) f += i;
  endfunction
endpackage
package q;
  import p::*;
  function int g();
    int o;
    t(o);
    return o + f();
  endfunction
endpackage
module top;
  int x;
  initial x = q::g();
endmodule
