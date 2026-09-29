// § strLitContOwnerEnd224 (a nested conditional in a package class method, the importer clone)
package p;
  class c;
    function string f(bit a, bit b);
      return a ? (b ? "x" : "y") : "ab \
cd";
    endfunction
  endclass
endpackage
module top(output string o);
  import p::*;
  c h;
  initial begin h = new; o = h.f(0, 1); end
endmodule
