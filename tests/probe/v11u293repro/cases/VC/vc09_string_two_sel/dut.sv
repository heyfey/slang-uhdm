// § cloneRetNameSelRefBindsHomeReturn293
// A string return written by two selects with bare reads between.
package p1;
  function string f();
    f = "abcd";
    f[0] = 8'h41;
    if (f.len() > 2) f[1] = 8'h42;
    f = {f, "!"};
  endfunction
endpackage
package p2;
  import p1::*;
  function int g();
    string s = f();
    return s.len();
  endfunction
endpackage
module top;
  import p2::*;
  int r_o;
  initial r_o = int'(g());
endmodule
