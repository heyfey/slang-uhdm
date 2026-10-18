// § classEnumViaHandleIsPath401
class C;
  typedef enum {A, B} e_t;
  int v;
  function void f(); v = this.B; endfunction
endclass
module top;
  C o;
  int r;
  initial begin o = new; r = o.A; end
endmodule
