// § namedUnlinkedWrittenOrder207: controls, resolved calls (a function declared before the caller, a module function, a task) keep the formal-slot list
package p;
class F;
  function bit mt(int o, int rt, string rtn, string fip = "", bit mot = 1, bit rn = 0);
    return mot;
  endfunction
  task tk(int a, int b = 2, output int c); c = a + b; endtask
  task g(int a);
    int c;
    if (mt(.rt(2), .o(a), .rtn("x"), .rn(1))) $display("a");
    tk(.c(c), .a(a));
  endtask
endclass
endpackage
module top(input int i, output int o);
  function int f(int a, int b = 1, int c = 2); return a + b + c; endfunction
  always_comb o = f(.c(i), .a(1));
endmodule
