// § namedUnlinkedWrittenOrder207: method calls through a handle with reordered and skipped named arguments (the method-call arms keep their pristine lists: measured)
package p;
class F;
  function bit mt(int o, int rt, string rtn, string fip = "", bit mot = 1, bit rn = 0);
    return mot;
  endfunction
  extern function int ex(int a, int b = 1, int c = 2);
endclass
class G;
  F f;
  function void h(int a);
    int r;
    if (f.mt(.rt(3), .o(a), .rtn("q"))) $display("m");
    if (f.mt(.o(a), .rt(3), .rtn("q"), .rn(1))) $display("n");
    r = f.ex(.c(a), .a(1));
  endfunction
endclass
function int F::ex(int a, int b = 1, int c = 2);
  return a + b + c;
endfunction
endpackage
module top; endmodule
