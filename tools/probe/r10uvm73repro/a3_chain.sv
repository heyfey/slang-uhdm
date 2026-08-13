// r10uvm73 arm a3 — THE CHAIN AXIS: how far does the degradation travel, and
// what LAUNDERS it.
//
// a2 produced the surprise the law has to absorb: a PACKAGE-scope typedef whose
// RHS is class-qualified (`typedef holder::e_t pkgalias_t;`) is itself an
// `unsupported_typespec` in golden, and a property typed by it degrades exactly
// like a directly-qualified one — while a CLASS-scope typedef with the SAME RHS
// (`typedef holder::e_t locloc_t;` inside the using class) resolves and does
// NOT degrade.  This arm asks whether the chain is followed one link or many,
// and whether a class-scope alias launders a package alias.
package p1;
  class holder;
    typedef enum {H_A, H_B} e_t;
  endclass

  typedef enum {P_A, P_B}  pkg_e_t;        // a plain package enum
  typedef pkg_e_t          pkgpkg_t;       // package alias OF a package typedef
  typedef holder::e_t      pkgcls_t;       // package alias OF a class typedef
  typedef pkgcls_t         pkgpkgcls_t;    // package alias of THAT alias

  class chain;
    typedef pkgcls_t     cls_of_pkgcls_t;  // CLASS alias of the poisoned alias
    typedef holder::e_t  cls_of_cls_t;     // CLASS alias of a class typedef

    pkgpkg_t        c_pkgpkg;              // control: two clean package links
    pkgcls_t        c_pkgcls;              // a2's c_pkgalias, restated
    pkgpkgcls_t     c_pkgpkgcls;           // TWO package links, the 2nd poisoned
    cls_of_pkgcls_t c_clsofpkgcls;         // does a CLASS alias launder it?
    cls_of_cls_t    c_clsofcls;            // a2's c_locloc, restated
  endclass
endpackage

module top;
  // a class declared INSIDE a module, not a package
  class mholder;
    typedef enum {M_A, M_B} m_e_t;
  endclass
  class muser;
    mholder::m_e_t c_mod_qual;             // class-qualified inside a MODULE
    typedef enum {N_A, N_B} n_e_t;
    n_e_t          c_mod_own;              // own typedef inside a MODULE class
  endclass
  p1::chain c;
  muser     m;
  initial begin c = new(); m = new(); end
endmodule
