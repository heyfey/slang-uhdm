// V11 — COMPLEX bound expressions under a select in a class scope: a function
// call, a nested bit_select, a ternary, a cast, and a hierarchical bound.
package v11_pkg;
  function automatic int lim(int x); return x + 1; endfunction
  class c11;
    int unsigned q11[$];
    logic [63:0] v11;
    int          idx[4];
    int          k;
    function automatic int by_call(int b);
      int unsigned t[$];
      t = q11[0 : lim(b)];              // bound is a FUNCTION CALL
      return t.size();
    endfunction
    function automatic int by_sel(int b);
      int unsigned t[$];
      t = q11[0 : idx[b]];              // bound is a BIT_SELECT
      return t.size();
    endfunction
    function automatic int by_tern(int b);
      int unsigned t[$];
      t = q11[0 : (b > 0 ? b : k)];     // bound is a TERNARY over a property
      return t.size();
    endfunction
    function automatic logic [7:0] idx_call(int b);
      return v11[lim(b) +: 8];          // indexed base is a FUNCTION CALL
    endfunction
    function automatic logic [7:0] idx_sel(int b);
      return v11[idx[b] -: 8];          // indexed base is a BIT_SELECT
    endfunction
  endclass
endpackage
module v11_bounds;
  v11_pkg::c11 h;
  int b0, b1, b2; logic [7:0] b3, b4;
  initial begin
    h = new();
    b0 = h.by_call(1); b1 = h.by_sel(2); b2 = h.by_tern(1);
    b3 = h.idx_call(0); b4 = h.idx_sel(1);
  end
endmodule
