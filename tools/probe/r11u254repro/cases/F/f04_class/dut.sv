// § forInitSelectLhsBase254 (a class property and a this. path as the for-loop initializer target)
module top(output int o);
  class c;
    int k;
    struct { int a; } st;
    function int run(); int n = 0; for (k = 0; k < 3; k++) n++; for (this.k = 0; this.k < 2; this.k++) n++; for (st.a = 0; st.a < 2; st.a++) n++; return n; endfunction
  endclass
  initial begin c h = new; o = h.run(); end
endmodule
