// r10v107 arm b6 — the REMAINING reference positions the brief names:
// a bare RETURN of the local, an INDEX, a CONCAT member, a REPLICATION, an
// UNDECLARED identifier, a MISSPELLED property, and the local as an argument of
// a receiver call in expression position at DEPTH 0 vs inside a nested block.
// MEASUREMENT ONLY.
package pb6;

  class d6;
    int fld;
  endclass

  class snk6;
    function int ask(d6 v);   return 0; endfunction
    function int askb(int a); return 0; endfunction
  endclass

  class c6 #(type T = d6);
    snk6 s;
    d6   plain;
    int  iq[4];
    extern function T    ret_bare();
    extern function int  idx_read();
    extern function int  cat_read();
    extern function int  rep_read();
    extern function void lhs_write();
    extern function int  cond_read();
    extern function void deep_block();
  endclass

  function c6::T c6::ret_bare();
    T v;
    return v;
  endfunction

  function int c6::idx_read();
    int ix;
    return iq[ix];
  endfunction

  function int c6::cat_read();
    int a6;
    int b6;
    return {a6, b6};
  endfunction

  function int c6::rep_read();
    int r6;
    return {4{r6}};
  endfunction

  function void c6::lhs_write();
    T v;
    v = plain;
  endfunction

  function int c6::cond_read();
    T v;
    if (v == null) return 1;
    return 0;
  endfunction

  function void c6::deep_block();
    T v;
    if (plain != null) begin
      if (s.ask(v) == 0) begin
        s.ask(v);
      end
    end
  endfunction

endpackage

module topb6;
  import pb6::*;
  c6 #(d6) inst;
  initial inst = new();
endmodule
