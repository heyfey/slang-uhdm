// r10uvm85 — AST probe.  Decodes the parse shape of STATEMENT-position
// implicit-class-handle calls, which is what selects Surelog's arm inside
// CompileHelper::compileComplexFuncCall.
//   surelog -parse -d ast -nobuiltin ast85.sv
module ast85;
  class inner85;
    int      arr[$];
    function void m85(); endfunction
  endclass
  class base85;
    int      bq[$];
  endclass
  class c85 extends base85;
    int      q[$];
    int      aa[string];
    inner85  h;
    inner85  hv[4];
    int      n;
    function void um85(int a); endfunction
    function void f();
      this.q.delete(0);            // L1  builtin, 1 arg, 2-deep
      this.q.delete();             // L2  builtin, 0 args
      this.q.insert(0, 1);         // L3  builtin, 2 args
      this.q.push_back(n);         // L4
      this.h.m85();                // L5  USER method, 2-deep
      this.um85(3);                // L6  bare this.<user>(arg)
      this.aa.delete("k");         // L7  assoc
      super.bq.delete(0);          // L8  super root
      this.super.bq.delete(0);     // L9  this.super root
      this.hv[1].m85();            // L10 INDEXED member
      this.h.arr.delete(0);        // L11 3-deep builtin
      void'(this.q.size());        // L12 cast-wrapped expression
      this.q.delete(this.n);       // L13 this-rooted ARG
      this.q.sort();               // L14 array-manipulation, 0 args
    endfunction
  endclass
endmodule
