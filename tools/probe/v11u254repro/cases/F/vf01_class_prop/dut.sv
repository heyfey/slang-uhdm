// § forInitSelectLhsBase254 (a class property struct member alone, and a class handle member from a module initial)
module top(output int o);
  class c;
    int k;
    struct { int a; } st;
    function int run(); int n = 0; for (st.a = 0; st.a < 2; st.a++) n++; return n; endfunction
  endclass
  initial begin c h = new; o = h.run(); for (h.k = 0; h.k < 3; h.k++) o++; end
endmodule
