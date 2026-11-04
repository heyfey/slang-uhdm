// § importCloneSharesHomeReturn218 — a class method returning a struct, the class imported by two packages (two clones)
package p;
  typedef struct { int a; logic [3:0] b; } rec_t;
  class c;
    function rec_t make(int x);
      rec_t r; r.a = x; r.b = 4'd2; return r;
    endfunction
  endclass
endpackage
package q1;
  import p::*;
  class d1 extends c; endclass
endpackage
package q2;
  import p::*;
  class d2 extends c; endclass
endpackage
module top;
endmodule
