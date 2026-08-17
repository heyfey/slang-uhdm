// vsd12 cell vd — INHERITANCE, which r10sd10's law names as the ONE case its
// ORDER term does not reconstruct ("the only way a bare name can reach a
// non-sibling owner at all is INHERITANCE ACROSS SCOPES ... named as a limit
// rather than hidden").  The corpus shape behind that sentence is
// `uvm_component::m_set_cl_action`'s `uvm_cmdline_parsed_arg_t t`, a SCALAR.
// This cell puts the same shape at a DECLARATOR ARRAY, both within one package
// and ACROSS packages, and with a VIRTUAL base class, because a `virtual class`
// is still a ClassType and the OWNER term cannot tell them apart.
package qvd;
  class qbase;
    typedef int qb_t;
  endclass
endpackage

package pvd;
  import qvd::*;

  virtual class abase;               // sorts BEFORE zderiv
    typedef int ab_t;
  endclass

  class zbase;                       // sorts AFTER mderiv
    typedef int zb_t;
  endclass

  class mderiv extends zbase;
    function void fm();
      zb_t   ib_q[$];                // BARE, INHERITED from a LATE-sorting base
      zb_t   ib_s;
      zbase::zb_t sb_q[$];           // the same, SCOPED
      zbase::zb_t sb_s;
      ib_q = {};
      sb_q = {};
    endfunction
  endclass

  class zderiv extends abase;
    function void fz();
      ab_t   ea_q[$];                // BARE, inherited from an EARLY base
      ab_t   ea_s;
      abase::ab_t sa_q[$];           // the same, SCOPED
      abase::ab_t sa_s;
      ea_q = {};
      sa_q = {};
    endfunction
  endclass

  class xderiv extends qvd::qbase;   // inherits ACROSS PACKAGES
    function void fx();
      qb_t   xb_q[$];                // BARE, inherited across packages
      qb_t   xb_s;
      qvd::qbase::qb_t xs_q[$];      // TWO segments, cross-package
      qvd::qbase::qb_t xs_s;
      xb_q = {};
      xs_q = {};
    endfunction
  endclass

endpackage

module topvd;
  initial begin
    pvd::mderiv m = new();
    pvd::zderiv z = new();
    pvd::xderiv x = new();
    m.fm(); z.fz(); x.fx();
  end
endmodule
