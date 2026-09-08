// v214 arm 3 — THE `!importCloneEmit` CONJUNCT: an EXPLICIT `import p::C;` item
// in a second package, beside the wildcard form.  Neither importer listing may
// bind (§ pkgCloneParamRefStaysBare178); only the home's def listing does.
package pv3src;
  parameter int sa3 = 11;
  parameter sb3 = sa3;
  function automatic int ssink3(int a, int b); return a + b; endfunction
  class S3;
    extern function int s_rd3();
  endclass
  function int S3::s_rd3();
    return ssink3(sa3, sb3);
  endfunction
endpackage
package pv3wild;
  import pv3src::*;
  parameter int wa3 = 2;
  class W3;
    extern function int w_rd3();
  endclass
  function int W3::w_rd3();
    return wa3;
  endfunction
endpackage
package pv3exp;
  import pv3src::S3;
  parameter int xa3 = 4;
  class X3;
    extern function int x_rd3();
  endclass
  function int X3::x_rd3();
    return xa3;
  endfunction
endpackage
module topv3;
  pv3src::S3 s = new();
  pv3wild::W3 w = new();
  pv3exp::X3 x = new();
  int a, b, c;
  initial begin a = s.s_rd3(); b = w.w_rd3(); c = x.x_rd3(); end
endmodule
