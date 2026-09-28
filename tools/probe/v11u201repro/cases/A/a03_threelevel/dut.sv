// § newArrayArgPathElemsStripped200
typedef struct { int n; } in_t;
typedef struct { in_t i; int m; } out_t;
class D;
  out_t o;
  byte d[];
  function void f(out_t p);
    d = new[p.i.n];
    d = new[o.i.n + p.m];
    d = new[p.i.n](d);
  endfunction
endclass
module top;
  D x;
  initial begin x = new; x.f(x.o); end
endmodule
