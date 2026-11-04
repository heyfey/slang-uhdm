// § newLhsHpSelFirstSpan437
class C; int v; endclass
class H; C c[2]; endclass
class K;
  H h;
  function void f(); h = new; h.c[1] = new; endfunction
endclass
module top; K k; initial begin k = new; k.f(); end endmodule
