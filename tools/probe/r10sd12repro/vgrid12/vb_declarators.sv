// vsd12 cell vb — SEVERAL DECLARATORS ON ONE DATA TYPE, and the LIFETIME axis.
// The peel reads `sym.getSyntax()->as<DeclaratorSyntax>().dimensions.size()`,
// i.e. THE DECLARATOR'S OWN dimension count.  A declaration list
// (`z::d_t a[$], b[2], c;`) puts THREE different dimension counts on ONE data
// type, so a peel that read the DECLARATION instead of the DECLARATOR would
// answer all three the same and be wrong on two of them.  No grid12 cell
// writes a declaration list at all.
//
// `static` / `automatic` block items and a `const` local are on the same axis:
// they change the variable's lifetime, not its class, so nothing may move.
package pvb;

  class zelvb;
    int q;
  endclass

  class zownb;                       // sorts AFTER auserb -> ClassVar arm
    typedef zelvb d_t;
    typedef int   i_t;
  endclass

  class auserb;
    function void fb();
      zownb::d_t a[$], b[2], c;              // THREE declarators, ONE data type
      zownb::i_t p[int], q2[3][2], r;        // and again over an INT typedef
      static  zownb::d_t s_q[$];             // STATIC lifetime
      automatic zownb::d_t au_q[$];          // AUTOMATIC lifetime
      const zownb::d_t k = null;             // const scalar control
      a = {};
      p[0] = 0;
      s_q = {};
      au_q = {};
      if (k == null) c = null;
    endfunction
  endclass

endpackage

module topvb;
  initial begin
    pvb::auserb u = new();
    u.fb();
  end
endmodule
