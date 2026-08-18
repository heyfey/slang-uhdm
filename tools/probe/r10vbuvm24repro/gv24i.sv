// r10vbuvm24repro/gv24i.sv — omission-form EDGE cases: arity 1 and 2, an
// output formal ahead of a defaulted input, a `ref` formal, and a
// PACKAGE-QUALIFIED call (`pkg::fn(1,,3)`, which keeps its func_call where a
// class-scoped `::` call collapses to a ref_obj).  MEASUREMENT ONLY.
package py24;
  function automatic int y1(int a = 1); return a; endfunction
  function automatic int y2(int a = 1, int b = 2); return a + b; endfunction
  function automatic int y3(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction
  function automatic void o2(output int x, input int y = 2); x = y; endfunction
  function automatic int r2(ref int x, input int y = 2); return x + y; endfunction
endpackage

module topy24;
  import py24::*;
  int v, w, rr;
  initial begin
    rr  = y1();
    rr += y1(1);
    // `y1(,)` is a SLANG REJECT: slang counts the leading and trailing empty
    // slots as TWO actuals for a one-formal function ("too many arguments"),
    // where Surelog accepts it.  Recorded, not exercised (R-OVERRUN).
    rr += y2(1,);
    rr += y2(,2);
    rr += y2(,);
    rr += y3(1,,3);
    o2(v,);
    rr += r2(w,);
    rr += py24::y3(1,,3);
    rr += py24::y2(,);
  end
endmodule
