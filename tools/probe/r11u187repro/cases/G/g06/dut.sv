// § cloneLoopVarHomeObject183 with § incDecMemberSelIsLvalue184
package u;
  typedef struct { int cnt[4]; } st_t;
  function automatic int tally(int q[$]);
    st_t st;
    foreach (q[i]) st.cnt[i]++;
    return st.cnt[0];
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
