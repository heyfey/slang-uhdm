// § cloneRetNameSelRefBindsHomeReturn293
// A method receiver on the return name beside the select write.
package p1;
  function string f();
    int k;
    f = "xyz";
    k = f.len() - 1;
    f[k] = 8'h42;
    f = f.substr(0, k);
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
