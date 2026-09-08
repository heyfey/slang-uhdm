// v209 verifier arm O — A PARAMETERIZED class's out-of-body constructor (the
// GenericClassDef -> default specialization walk) and an EXPLICIT import of a
// single package variable, beside a wildcard one.
package po209;
  class co209a;
    int n;
  endclass
  class co209p #(int W = 4);
    int q;
    extern function new();
  endclass
  function co209p::new();
    co209a        lo_h;
    static co209a lo_h_static;
    int           lo_i;
    lo_h = null;
    q = W;
  endfunction
  co209a po_own;
  int    po_int;
endpackage

module go209;
  import po209::po_int;
  import po209::*;
  initial $display("o");
endmodule
