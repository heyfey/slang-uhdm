// t47a — pass 35, cell A: WHO owns a class-key typespec an import publishes,
// when the importers are PACKAGES.
//
// § importPublishesPackageClasses24 says an import inserts every class of the
// imported package into the importing scope's DataTypeMap at the CLASS NAME
// key, and `UhdmWriter::writeDataTypes` (:775) then
//   * qualifies a still-unqualified name with the PACKAGE it writes for, and
//   * stamps `vpiInstance` = that scope, but only `if (!tps->Instance())` and
//     only when the scope is not a `class_defn`.
// So the owner should be the FIRST non-class scope that lists the object.
// Two importers pin which one that is, and their names are deliberately
// ANTI-SORTED against their declaration order: `zz47` is declared first,
// `aa47` second.  If the owner is `aa47` the order is std::map name order; if
// it is `zz47` it is source order; if it is the LAST one this is a
// § pkgImportAggCloneLastWriter32-shaped law instead.
//
// `mm47` imports too, so the module views can be ranked against the packages.
// `plain47_t` is the CONTROL: an ordinary package typedef, which the importer
// lists under its OWN name key, not a class key.

package pcls47;
  // the class that DECLARES this_type, used as a formal by its own method
  class base47;
    typedef base47 this_type;
    virtual function void b_this(this_type p); endfunction
  endclass

  // a PARAMETERISED class and a derived one that only INHERITS this_type:
  // the UVM socket shape (`uvm_tlm_b_initiator_socket::connect(this_type)`),
  // which in golden binds a SHARED object and in ours mints a duplicate.
  class gen47 #(type T47 = int);
    typedef gen47 #(T47) this_type;
    virtual function void g_this(this_type p); endfunction
  endclass

  class sub47 #(type T47 = int) extends gen47 #(T47);
    virtual function void s_this(this_type p); endfunction
  endclass

  class subi47 extends gen47 #(int);
    virtual function void si_this(this_type p); endfunction
  endclass

  // the UVM SOCKET shape: the base's type argument DEPENDS on the derived
  // class's own parameter, so every socket gets its OWN specialization of the
  // base and, in our emitter, its own UNLISTED duplicate of the base's
  // `this_type` typespec (golden binds the one shared object).
  class holder47 #(type T47 = int);
    T47 h;
  endclass
  class sock47 #(type T47 = int) extends gen47 #(holder47 #(T47));
    virtual function void k_this(this_type p); endfunction
  endclass
  class sockb47 #(type T47 = bit) extends gen47 #(holder47 #(T47));
    virtual function void kb_this(this_type p); endfunction
  endclass

  // CONTROL: an ordinary package typedef used as a formal.
  typedef int plain47_t;
  // CONTROL: a class with NO class-scope typedef at all, so its class-key
  // REPRESENTATIVE is a typespec named after the CLASS.  A plain `nocls47 n`
  // formal must NOT pick up the representative's owner — this is the cell
  // that keeps the duplicate law from being written too wide.
  class nocls47;
    int x47;
  endclass
  class use47;
    virtual function void u_pl(plain47_t p); endfunction
    virtual function void u_no(nocls47 n); endfunction
    virtual function void u_cl(base47 b); endfunction
  endclass
endpackage

// declared FIRST, sorts LAST
package zz47;
  import pcls47::*;
  class uz47;
    virtual function void z_this(base47::this_type p); endfunction
  endclass
endpackage

// declared SECOND, sorts FIRST
package aa47;
  import pcls47::*;
  class ua47;
    virtual function void a_this(base47::this_type p); endfunction
    virtual function void a_no(nocls47 n); endfunction
    virtual function void a_cl(base47 b); endfunction
  endclass
endpackage

module mm47;
  import pcls47::*;
  base47 h47;
  initial h47 = null;
endmodule
