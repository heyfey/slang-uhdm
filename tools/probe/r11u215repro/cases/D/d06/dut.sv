// § incDecOperandKeepsLvalueForm215 — a two-level member path in a call argument, a struct variable in a module's procedural call, both views
package p;
  class inner; int c; endclass
  class outer; inner b; endclass
  function automatic void take(int i); endfunction
  class sqr;
    outer a;
    function void send();
      take(a.b.c++);
      take(++a.b.c);
    endfunction
  endclass
endpackage
module m;
  typedef struct { int f; int g; } s_t;
  s_t s;
  function automatic int id(int x); return x; endfunction
  int r;
  always_comb begin
    r = id(s.f++);
    r = id(++s.g);
  end
endmodule
