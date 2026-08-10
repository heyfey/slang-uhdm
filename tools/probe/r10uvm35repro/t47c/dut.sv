// t47c — pass 35, cell C: the NO-IMPORTER control.
//
// BuildUVMPkg compiles uvm_pkg and nobody imports it, and golden's `this_type`
// objects there carry a NULL vpiInstance and a BARE name — because the only
// scope that ever lists them is a `class_defn`, and `writeDataTypes` skips the
// stamp for that parent (`if (parent->UhdmType() != uhdmclass_defn)`).
//
// A MODULE importer is also here (`mm47`) to rank the module views against
// "nobody": if a module importer stamps, the BuildUVMPkg null cannot be
// explained by "no package importer" alone.

package pcls47;
  class base47;
    typedef base47 this_type;
    virtual function void b_this(this_type p); endfunction
  endclass

  class gen47 #(type T47 = int);
    typedef gen47 #(T47) this_type;
    virtual function void g_this(this_type p); endfunction
  endclass

  class sub47 #(type T47 = int) extends gen47 #(T47);
    virtual function void s_this(this_type p); endfunction
  endclass

  typedef int plain47_t;
  class use47;
    virtual function void u_pl(plain47_t p); endfunction
  endclass
endpackage

module mm47;
  import pcls47::*;
  base47 h47;
  initial h47 = null;
endmodule

module nn47;
  initial begin end
endmodule
