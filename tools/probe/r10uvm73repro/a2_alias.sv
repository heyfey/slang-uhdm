// r10uvm73 arm a2 — THE ALIAS / ORDER / PARAMETERISATION AXES.
//
// a1 established: a class PROPERTY whose declared type is a typedef living in a
// CLASS scope reached by a `::` class qualifier OR by INHERITANCE degrades to a
// bare logic_var with no typespec; a package/$unit typedef and an OWN-class
// unqualified typedef do not.  This arm asks the four questions that gate must
// answer before it can be written down: does an ALIAS launder the class scope,
// does DECLARATION ORDER matter, does a PARAMETERISED class scope behave the
// same, and does the rule survive a second package.
package p1;
  class holder;
    typedef enum {H_A, H_B} e_t;
    typedef holder self_t;                 // a class-scope handle typedef
  endclass

  typedef holder::e_t pkgalias_t;          // PACKAGE-scope alias of a class type

  class base2;
    typedef enum {B_A, B_B} b_e_t;
  endclass
  class mid2 extends base2;
  endclass

  class aliasuser;
    typedef holder::e_t locloc_t;          // CLASS-scope alias of a class type
    pkgalias_t   c_pkgalias;               // via a PACKAGE alias
    locloc_t     c_locloc;                 // via an OWN-CLASS alias
    holder::self_t c_qual_handle;          // class-qualified CLASS-HANDLE typedef
    typedef enum {F_A, F_B} e_fwd_t;
    e_fwd_t      c_fwd;                    // own typedef, declared BEFORE use
  endclass

  class grand extends mid2;
    b_e_t        c_grand_inh;              // typedef TWO levels up, unqualified
    base2::b_e_t c_grand_qual;             // ...and the same one, qualified
  endclass

  class pholder #(type T = int);
    typedef enum {G_A, G_B} g_e_t;
  endclass

  class puser;
    pholder#(int)::g_e_t c_param_qual;     // PARAMETERISED class scope, qualified
  endclass
endpackage

package p2;
  class p2holder;
    typedef enum {Q_A, Q_B} q_e_t;
  endclass
  class p2user;
    p1::holder::e_t c_xpkg_qual;           // pkg::class::typedef, other package
    p2holder::q_e_t c_samepkg_qual;        // class-qualified, same package
  endclass
endpackage

module top;
  p1::aliasuser a;
  p1::grand     g;
  initial begin a = new(); g = new(); end
endmodule
