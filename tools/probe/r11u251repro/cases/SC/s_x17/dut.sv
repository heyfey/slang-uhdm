// § ppStrEndNotTokStart251
`define Q3(F, P, T) \
  do begin \
    int curr, max__; \
    pr p__; \
    p__.print_array_header(`"F`", curr, `"T``(string)`");\
  end while(0);
`define A2(F, P) \
   `Q3(F, P, da)
class sc; function void set_arg(string s); endfunction function int depth(); return 0; endfunction endclass
class kn; int depth; int begin_elements; int end_elements; endclass
class pr; sc m_scope; kn knobs;
  function void print_array_header(string a, int b, string c); endfunction
  function void print_string(string a, string b, string c); endfunction
  function string index_string(int i); return ""; endfunction
  function void print_array_range(int a, int b); endfunction
  function void print_array_footer(int a); endfunction
endclass
module top; string abstractions[$]; pr q; initial `A2(abstractions, q) endmodule
