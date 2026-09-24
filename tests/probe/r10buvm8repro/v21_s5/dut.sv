package s21;
  import "DPI-C" context function int d21(input int a, input int b, input int c);
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } st_t;
  function int f2   (int a, int b);                 return d21(a, b, 0); endfunction
  function int fd   (int a, int b = 7);             return d21(a, b, 0); endfunction
  function int fstr (string a, string b);           return d21(a.len(), b.len(), 0); endfunction
  function int f4   (int a, int b, int c, int d);   return d21(a, b, c) + d; endfunction
  function int fnib (logic [3:0] a, int b);         return d21(int'(a), b, 0); endfunction
  function automatic int fref (ref int a, int b);   return d21(a, b, 0); endfunction
  function int s5 (st_t s, int a); return fnib(s.hi, a); endfunction
endpackage
module m_s5;
  int r; s21::st_t ss;
  initial r=s21::s5(ss,1);
endmodule
