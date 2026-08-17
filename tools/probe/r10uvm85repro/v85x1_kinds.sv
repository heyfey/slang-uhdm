// v85x1 — EVERY BUILT-IN KIND in statement position on a `this.<member>`
// receiver, arities 0..3, plus the return-value forms wrapped in `void'(...)`.
// The law claims ONE method_func_call named after the ROOT, prefix the handle
// constant, arguments kept at depth 1.  Anything golden shapes differently
// here is a pristine-right -> patched-wrong candidate.
module v85x1;
  class in1v;
    int arr[$];
    int m;
  endclass
  class c1v;
    int      q[$];
    int      dy[];
    int      aa[string];
    int      ai[int];
    string   s;
    in1v     h;
    int      n;
    string   idx;
    int      ii;
    function void um3(int a, int b, int c); endfunction
    function void f(int k);
      // ---- QUEUE, arities 0..2
      this.q.delete();                 // L23 0 args
      this.q.delete(0);                // L24 1
      this.q.insert(0, k);             // L25 2
      this.q.push_back(k);             // L26 1
      this.q.push_front(k);            // L27 1
      void'(this.q.pop_front());       // L28 0, value dropped
      void'(this.q.pop_back());        // L29 0
      void'(this.q.size());            // L30 0
      this.q.sort();                   // L31 0
      this.q.rsort();                  // L32 0
      this.q.reverse();                // L33 0
      this.q.shuffle();                // L34 0
      // ---- DYNAMIC ARRAY
      this.dy.delete();                // L36 0
      void'(this.dy.size());           // L37 0
      // ---- ASSOC ARRAY, incl. REF-argument iterators
      this.aa.delete("x");             // L39 1 string
      this.aa.delete();                // L40 0
      void'(this.aa.exists("x"));      // L41 1
      void'(this.aa.num());            // L42 0
      void'(this.aa.first(this.idx));  // L43 1 REF actual, this-rooted
      void'(this.aa.next(this.idx));   // L44 1 REF actual
      void'(this.ai.last(this.ii));    // L45 1 REF actual
      // ---- STRING methods
      void'(this.s.len());             // L47 0
      void'(this.s.substr(0, 1));      // L48 2
      this.s.putc(0, "a");             // L49 2
      void'(this.s.getc(0));           // L50 1
      void'(this.s.toupper());         // L51 0
      void'(this.s.compare(this.s));   // L52 1
      this.s.itoa(k);                  // L53 1
      void'(this.s.atoi());            // L54 0
      // ---- USER method arity 3, depth 1 and depth 2
      this.um3(k, k, k);               // L56 one-step USER, 3 args
      this.h.arr.delete(k);            // L57 depth-2 builtin (args dropped?)
      this.n = 0;
    endfunction
  endclass
endmodule
