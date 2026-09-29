// § strLitPpEscIdShift224 (a package class method, a call after the literal on the line; the importer clone)
package p;
  class c;
    function int f();
      string s; s = "a\nb` c"; return s.len();
    endfunction
  endclass
endpackage
module top(output int o);
  import p::*;
  c h;
  initial begin h = new; o = h.f(); end
endmodule
