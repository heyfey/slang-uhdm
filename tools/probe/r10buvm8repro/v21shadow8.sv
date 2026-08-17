// VERIFIER arm: the NAME-SHADOW sub-law crossed with every other fence —
// omitted DEFAULT formals, a CONSTANT at the shadowed position, a STRING
// LITERAL on a string formal (the !strFormalConst fence), a hier_path at the
// position whose formal name is reused, FOUR formals, a ref formal, and a
// NESTED call at position 0.
package s21;
  import "DPI-C" context function int d21(input int a, input int b, input int c);
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } st_t;
  function int f2   (int a, int b);                 return d21(a, b, 0); endfunction
  function int fd   (int a, int b = 7);             return d21(a, b, 0); endfunction
  function int fstr (string a, string b);           return d21(a.len(), b.len(), 0); endfunction
  function int f4   (int a, int b, int c, int d);   return d21(a, b, c) + d; endfunction
  function int fnib (logic [3:0] a, int b);         return d21(int'(a), b, 0); endfunction
  function automatic int fref (ref int a, int b);   return d21(a, b, 0); endfunction
  // s1 default OMITTED, actual name == formal 0's name
  function int s1 (int a);        return fd(a); endfunction
  // s2 default OMITTED, actual name == the OMITTED formal's name
  function int s2 (int b);        return fd(b); endfunction
  // s3 constant at pos0 (formal a), bare `a` at pos1
  function int s3 (int a);        return f2(1, a); endfunction
  // s4 string LITERAL on a string formal at pos0, bare `a` at pos1
  function int s4 (string a);     return fstr("lit", a); endfunction
  // s5 hier_path at pos0 (formal a takes NO stamp), bare `a` at pos1
  function int s5 (st_t s, int a); return fnib(s.hi, a); endfunction
  // s6 FOUR formals (a,b,c,d), all four actuals spelled `a`
  function int s6 (int a);        return f4(a, a, a, a); endfunction
  // s7 FOUR formals, actuals REVERSED
  function int s7 (int a, int b, int c, int d); return f4(d, c, b, a); endfunction
  // s8 REF formal at pos0, bare `a` at pos1
  function int s8 (int a);        int t; t = a; return fref(t, a); endfunction
  // s9 NESTED call at pos0, bare `a` at pos1
  function int s9 (int a);        return f2(f2(a, 1), a); endfunction
endpackage
module m21;
  int r[9]; s21::st_t ss;
  initial begin
    r[0]=s21::s1(1); r[1]=s21::s2(1); r[2]=s21::s3(1); r[3]=s21::s4("x");
    r[4]=s21::s5(ss,1); r[5]=s21::s6(1); r[6]=s21::s7(1,2,3,4);
    r[7]=s21::s8(1); r[8]=s21::s9(1);
  end
endmodule
