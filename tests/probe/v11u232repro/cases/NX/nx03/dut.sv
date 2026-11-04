// § structCopyNestedAnnotDeep232
// member defaults in a class and a module-local typedef
class C;
  typedef struct { int a = 3; } s_t;
  s_t m;
  function int get(); return m.a; endfunction
endclass
module top(output int o);
  typedef struct { int b = 2; struct { int c = 7; } n; } t_t;
  t_t v;
  assign o = v.b + v.n.c;
endmodule
