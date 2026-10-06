// § forMultiInitAssign258 (a class property's struct member and a class property, r11u254 f04's shape with two initializers)
module top(output int o);
  class c;
    int k;
    struct { int a; } st;
    function int run(); int n = 0; for (st.a = 0, k = 0; st.a < 2; st.a++) n++; for (k = 0, st.a = 1; k < 3; k++) n++; return n; endfunction
  endclass
  initial begin c h = new; o = h.run(); end
endmodule
