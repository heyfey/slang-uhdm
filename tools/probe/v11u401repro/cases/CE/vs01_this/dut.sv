// § classEnumViaHandleIsPath401
class C;
  typedef enum {A, B, CC} e_t;
  e_t v;
  function void f(); v = this.B; endfunction
endclass
module top;
  C o;
  initial begin o = new; o.v = o.CC; end
endmodule
