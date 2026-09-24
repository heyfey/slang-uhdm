// ARG-KIND matrix B: struct/hier_path, enum, real, ref, output, inout,
// defaulted formal, queue, unpacked array, class handle, chandle, event.
package kp5b;
  typedef logic [7:0] b_t;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } s_t;
  typedef enum logic [1:0] { E0, E1 } e_t;
  import "DPI-C" context function int dpi5(input int a);
  function int f1 (int a);            return dpi5(a); endfunction
  function int fs (s_t s);            return dpi5(int'(s)); endfunction
  function int fe (e_t e);            return dpi5(int'(e)); endfunction
  function int fr (real r);           return dpi5(int'(r)); endfunction
  function automatic int fref (ref b_t r);      return dpi5(int'(r)); endfunction
  function int fout (b_t i, output b_t o); o = i; return dpi5(int'(i)); endfunction
  function int finout (inout b_t io); return dpi5(int'(io)); endfunction
  function int fdef (int a, int b = 7); return dpi5(a + b); endfunction
  function int fbit (logic l);        return dpi5(int'(l)); endfunction
  function int k_hierarg (s_t s);   return f1(int'(s.hi)); endfunction
  function int k_hierdirect (s_t s); return fbit(s.hi[0]); endfunction
  function int k_struct (s_t s);    return fs(s); endfunction
  function int k_enum (e_t e);      return fe(e); endfunction
  function int k_real (real r);     return fr(r); endfunction
  function int k_ref (b_t a);       return fref(a); endfunction
  function int k_out (b_t a);       b_t o; return fout(a, o); endfunction
  function int k_inout (b_t a);     return finout(a); endfunction
  function int k_default (int a);   return fdef(a); endfunction
  function int k_defexpl (int a);   return fdef(a, 9); endfunction
endpackage
module m5b;
  int r[10]; kp5b::b_t bb; kp5b::s_t ss; kp5b::e_t ee;
  initial begin
    r[0]=kp5b::k_hierarg(ss); r[1]=kp5b::k_hierdirect(ss); r[2]=kp5b::k_struct(ss);
    r[3]=kp5b::k_enum(ee); r[4]=kp5b::k_real(1.0); r[5]=kp5b::k_ref(bb);
    r[6]=kp5b::k_out(bb); r[7]=kp5b::k_inout(bb); r[8]=kp5b::k_default(1);
    r[9]=kp5b::k_defexpl(1);
  end
endmodule
