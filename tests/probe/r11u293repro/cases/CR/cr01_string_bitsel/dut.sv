// § cloneRetNameSelRefBindsHomeReturn293
// A string function writes a select of its return name; a wildcard importer clones it.
package p1;
  function string f();
    int i; i = 0;
    f = "ab";
    f[i] = 8'h41;
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
