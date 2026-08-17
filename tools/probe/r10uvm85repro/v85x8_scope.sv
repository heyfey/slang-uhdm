// v85x8 — SCOPES AND VIEWS.  A PARAMETERIZED class (emitted once per
// specialization), a class in a PROGRAM and in an INTERFACE, a STATIC member as
// the first step, a VIRTUAL method overridden in a derived class, a nested class
// type, and a package class imported by TWO modules (two hoisting views of the
// same body).
package p85x8;
  class pc8 #(int W = 4);
    int      q[$];
    static int sq[$];
    int      n;
    function void f(int k);
      this.q.delete(k);          // L11 parameterized class body
      this.sq.delete(k);         // L12 STATIC member as the first step
      this.n = W;
    endfunction
  endclass
  class base8;
    int bq[$];
    virtual function void vf(int k);
      this.bq.delete(k);         // L18 VIRTUAL base body
    endfunction
  endclass
  class der8 extends base8;
    int dq[$];
    virtual function void vf(int k);
      this.dq.delete(k);         // L24 OVERRIDE body
      super.bq.delete(k);        // L25 super root in an override
    endfunction
  endclass
endpackage
module v85x8a;
  import p85x8::*;
  pc8 #(8) h8;
  der8     d8;
endmodule
module v85x8b;
  import p85x8::*;
  pc8 #(4) h4;
endmodule
program v85x8p;
  class inp8;
    int q[$];
    function void f(int k);
      this.q.delete(k);          // L44 class inside a PROGRAM
    endfunction
  endclass
endprogram
interface v85x8i;
  class ini8;
    int q[$];
    function void f(int k);
      this.q.delete(k);          // L53 class inside an INTERFACE
    endfunction
  endclass
endinterface
