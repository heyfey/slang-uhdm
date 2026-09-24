// t47b — pass 35, cell B: the same publication with a `$unit`-SCOPE import.
//
// Scoreboard and SimpleUVM import uvm_pkg at `$unit` scope and golden's
// class-key typespecs come out owned by the DESIGN object (VpiName empty,
// VpiFullName `work@<top>`), with the name left BARE.  Surelog writes the
// FileContent DataTypeMaps into `design->Typespecs()` (UhdmWriter.cpp:4871)
// before any package or module, and `writeDataTypes` only qualifies a name
// when the scope it writes for is a package — so a `$unit` import should beat
// every package importer AND leave the name unqualified.
//
// `zz47`/`aa47` are here too, so this arm also says whether the design really
// wins over a package importer or merely happens to be the only one.

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

package zz47;
  import pcls47::*;
  class uz47;
    virtual function void z_this(base47::this_type p); endfunction
  endclass
endpackage

package aa47;
  import pcls47::*;
  class ua47;
    virtual function void a_this(base47::this_type p); endfunction
  endclass
endpackage

// the `$unit`-scope import — the Scoreboard / SimpleUVM shape
import pcls47::*;

module mm47;
  base47 h47;
  initial h47 = null;
endmodule
