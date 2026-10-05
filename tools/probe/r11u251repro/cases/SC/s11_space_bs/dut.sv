// § ppStrEndNotTokStart251
`define Q3(F, P, T) \
  do begin \
    int curr, max__; \
    pr p__; \
    max__=0; curr=0; \
    //max__=$size(F); \
    foreach(F[i]) max__ = i+1; \
    if(P!=null) p__ = P; \
    else p__ = null; \
\
    //p__.print_header();\
\
    p__.m_scope.set_arg(`"F`");\
    p__.print_array_header(`"F`", max__, `"T``(string)`"); \
    if((p__.knobs.depth == -1) || (p__.knobs.depth+1 > p__.m_scope.depth())) \
    begin\
      for(curr=0; curr<max__ && curr<p__.knobs.begin_elements; ++curr) begin\
        p__.print_string(p__.index_string(curr), F[curr], "[");\
      end \
      if(curr<max__) begin\
        curr = max__-p__.knobs.end_elements;\
        if(curr<p__.knobs.begin_elements) curr = p__.knobs.begin_elements;\
        else begin\
          p__.print_array_range(p__.knobs.begin_elements, curr-1);\
        end\
        for(curr=curr; curr<max__; ++curr) begin\
          p__.print_string(p__.index_string(curr), F[curr], "[");\
        end \
      end\
    end \
\
    p__.print_array_footer(max__); \
    //p__.print_footer(); \
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
