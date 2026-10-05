// § hpFnStaticTrailScopeJoin246
package p;
  class c;
    int a[8];
    bit [15:0] w;
    function void st();
      static int idx;
      static int cnt;
      idx = 0;
    endfunction
    function void usr();
      st.cnt++;
      a[st.idx] = 1;
      a[st.idx + 1] = st.cnt;
      w[st.idx +: 4] = 4'h3;
      if (st.cnt > 0) st.idx = -st.cnt;
    endfunction
  endclass
endpackage
module top;
endmodule
