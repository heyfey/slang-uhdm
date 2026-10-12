// § cloneRetNameSelRefBindsHomeReturn293
// CONTROL: an out-of-body class method in the home (golden-null in the clone, § homeRetNameSelBindSurvivesDefViewUnbind194).
package p1;
  class C;
    extern function string m();
  endclass
  function string C::m();
    int i; i = 0;
    m = {m, " "};
    m[i] = 8'h41;
  endfunction
endpackage
package p2;
  import p1::*;
  function int g();
    C h = new();
    string a = h.m();
    return a.len();
  endfunction
endpackage
module top;
  import p2::*;
  int r_o;
  initial r_o = int'(g());
endmodule
