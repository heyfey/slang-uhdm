// vsd10 adversarial cell v8 — a class inside a GENERATE BLOCK and a class
// inside a PROGRAM: parent scopes the predicate's `nameableScope` test does not
// enumerate, so even a SELF-qualified own typedef takes the fallback.
program prg8;
  class zprg8;
    typedef struct { int a; } r_t;
  endclass
  class aprg8;
    typedef struct { int m; } own_t;
    function void f();
      zprg8::r_t   v_prg_sib;
      aprg8::own_t v_prg_self;
      v_prg_sib.a = 1;
      v_prg_self.m = 2;
    endfunction
  endclass
  aprg8 a;
  initial a = new();
endprogram

module top8;
  if (1) begin : gb
    class zgen8;
      typedef struct { int a; } r_t;
    endclass
    class agen8;
      typedef struct { int m; } own_t;
      function void f();
        agen8::own_t v_gen_self;   // OWN typedef, self-qualified, in a genblock
        zgen8::r_t   v_gen_sib;
        v_gen_self.m = 1;
        v_gen_sib.a = 2;
      endfunction
    endclass
    agen8 a;
    initial a = new();
  end
endmodule
