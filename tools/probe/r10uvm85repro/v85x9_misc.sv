// v85x9 — CONSTRUCTORS, the std:: container classes, the PROCESS handle (the
// corpus's only depth-3 witness spelling), and the two casts that wrap a call.
module v85x9;
  class in9;
    int arr[$];
    process p;
    function void im(int a); endfunction
  endclass
  class b9;
    int bq[$];
    function new(int x); this.bq.delete(x); endfunction   // L11 in BASE ctor
  endclass
  class c9 extends b9;
    in9      h;
    in9      hv[2];
    mailbox  mbx;
    semaphore sem;
    int      q[$];
    int      n;
    function new();
      super.new(1);                 // L21 super.new
      this.q.delete(0);             // L22 head statement inside a CONSTRUCTOR
      this.h = new();               // L23 constructor call as an rvalue
    endfunction
    task t9(int k);
      this.mbx.put(k);              // L26 std::mailbox method, depth 1
      this.mbx.get(this.n);         // L27 REF actual
      this.sem.put(1);              // L28 std::semaphore
      this.sem.get(1);              // L29
      this.hv[k].p.kill();          // L30 THE CORPUS SPELLING: idx, name, 0-arg
      this.h.p.kill();              // L31 same, unindexed first step
      void'($cast(this.n, k));      // L32 $cast with a this-rooted output
      this.q.delete(int'(k));       // L33 CAST actual
      this.n = 0;
    endtask
  endclass
endmodule
