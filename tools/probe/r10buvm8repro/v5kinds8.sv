// ARG-KIND x POSITION matrix, all callees declared BEFORE their callers.
package kp5;
  typedef logic [7:0] b_t;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } s_t;
  typedef enum logic [1:0] { E0, E1 } e_t;
  import "DPI-C" context function int dpi5(input int a);
  function int f1 (int a);              return dpi5(a); endfunction
  function int f3 (int a, b_t b, string c); return dpi5(a) + int'(b) + c.len(); endfunction
  function int fs (s_t s);              return dpi5(int'(s)); endfunction
  function int fe (e_t e);              return dpi5(int'(e)); endfunction
  function int fr (real r);             return dpi5(int'(r)); endfunction
  function int fref (ref b_t r);        return dpi5(int'(r)); endfunction
  function int fout (b_t i, output b_t o); o = i; return dpi5(int'(i)); endfunction
  function int fdef (int a, int b = 7);  return dpi5(a + b); endfunction
  function int fq (int q[$]);           return dpi5(q.size()); endfunction
  // ---------------- callers, one law-window return each
  function int k_const ();     return f1(3); endfunction
  function int k_strlit ();    return f3(1, 8'h2, "lit"); endfunction
  function int k_op (int a);   return f1(a + 1); endfunction
  function int k_concat (b_t a); return f3(1, {a[3:0], a[7:4]}, "x"); endfunction
  function int k_tern (int a); return f1(a ? 1 : 2); endfunction
  function int k_bitsel (b_t a); return f3(1, {7'b0, a[0]}, "x"); endfunction
  function int k_partsel (b_t a); return f3(1, {4'b0, a[3:0]}, "x"); endfunction
  function int k_ipsel (b_t a);  return f3(1, {4'b0, a[3-:4]}, "x"); endfunction
  function int k_bitsel_direct (b_t a); return fbit(a[0]); endfunction
  function int fbit (logic l);  return dpi5(int'(l)); endfunction
  function int k_hier (s_t s); return f1(int'(s.hi)); endfunction
  function int k_hierdirect (s_t s); return fbit(s.hi[0]); endfunction
  function int k_struct (s_t s); return fs(s); endfunction
  function int k_enum (e_t e);  return fe(e); endfunction
  function int k_real (real r); return fr(r); endfunction
  function int k_ref (b_t a);   return fref(a); endfunction
  function int k_out (b_t a);   b_t o; return fout(a, o); endfunction
  function int k_default (int a); return fdef(a); endfunction
  function int k_pos3 (int a, b_t b, string c); return f3(a, b, c); endfunction
  function int k_nested (int a); return f1(f1(a)); endfunction
  function int k_sysnest (int a); return f1($signed(a)); endfunction
  function int k_cast (b_t a);  return f1(int'(a)); endfunction
  function int k_param ();      return f1(PP); endfunction
  localparam int PP = 5;
  function int k_twocalls (int a, int b); return f1(a) + f1(b); endfunction
  function int k_q (int qq[$]); return fq(qq); endfunction
endpackage
module m5;
  int r[24];
  kp5::b_t bb; kp5::s_t ss; kp5::e_t ee; int qq[$];
  initial begin
    r[0]=kp5::k_const(); r[1]=kp5::k_strlit(); r[2]=kp5::k_op(1);
    r[3]=kp5::k_concat(bb); r[4]=kp5::k_tern(1); r[5]=kp5::k_bitsel(bb);
    r[6]=kp5::k_partsel(bb); r[7]=kp5::k_ipsel(bb); r[8]=kp5::k_bitsel_direct(bb);
    r[9]=kp5::k_hier(ss); r[10]=kp5::k_hierdirect(ss); r[11]=kp5::k_struct(ss);
    r[12]=kp5::k_enum(ee); r[13]=kp5::k_real(1.0); r[14]=kp5::k_ref(bb);
    r[15]=kp5::k_out(bb); r[16]=kp5::k_default(1); r[17]=kp5::k_pos3(1,bb,"s");
    r[18]=kp5::k_nested(1); r[19]=kp5::k_sysnest(1); r[20]=kp5::k_cast(bb);
    r[21]=kp5::k_param(); r[22]=kp5::k_twocalls(1,2); r[23]=kp5::k_q(qq);
  end
endmodule
