// § hpFnStaticTrailScopeJoin246
module top;
  class c;
    function void st();
      static int idx;
      idx++;
    endfunction
    function int get();
      return st.idx;
    endfunction
  endclass
  c h;
  int r;
  initial begin h = new; r = h.get(); end
endmodule
