// § importCloneBodyLocalCopies175
package p1;
  class c;
    static function int s(int n);
      int loc = n * 2;
      string nm = "s";
      return loc + nm.len();
    endfunction
    function automatic int a(int m);
      int q[$] = {m};
      return q.size();
    endfunction
  endclass
endpackage
package p2;
  import p1::*;
  int z;
endpackage
module top; import p1::*; c o; int r; initial begin o = new; r = c::s(1) + o.a(2); end endmodule
