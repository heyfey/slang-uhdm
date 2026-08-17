// r10sd10 grid cell g3 — the CONTEXT axis.  The same `Owner::td` spelling in
// every declaration context Surelog compiles at a different stage: a PACKAGE
// variable, a MODULE variable, an initial-block local, a class-in-module method
// local, and a class method local whose owner lives in ANOTHER package.  Plus
// the PACKAGE-scope spelling (`pkg::td`), which takes `compileVariable`'s
// getPackage() arm and never reaches the class arm at all.
package qy;
  typedef struct { int a; } qrec_t;      // package-scope typedef, no class
  class qholder;
    typedef struct { int a; } qsrec_t;   // class in ANOTHER package
  endclass
endpackage

package px;

  class aholder;
    typedef struct { int a; } srec_t;
  endclass

  class zholder;
    typedef struct { int a; } srec_t;
  endclass

  class auser;                            // sorts BEFORE zholder
    function void f();
      zholder::srec_t   c_late_struct;    // owner sorts AFTER  -> class_var
      aholder::srec_t   c_early_struct;   // owner sorts BEFORE -> struct_var
      qy::qholder::qsrec_t c_other_pkg;   // owner in another package
      qy::qrec_t        c_pkg_scope;      // PACKAGE scope, not a class
      c_late_struct.a = 1;
      c_early_struct.a = 1;
      c_pkg_scope.a = 1;
    endfunction
  endclass



  // PACKAGE-scope variables of the same scoped types
  zholder::srec_t pkgvar_late;
  aholder::srec_t pkgvar_early;

endpackage

module top;
  // MODULE-scope variables
  px::zholder::srec_t modvar_late;
  px::aholder::srec_t modvar_early;

  class muser;                            // a class declared INSIDE a module
    function void g();
      px::zholder::srec_t m_late_struct;
      px::aholder::srec_t m_early_struct;
      m_late_struct.a = 1;
      m_early_struct.a = 1;
    endfunction
  endclass

  initial begin
    px::zholder::srec_t init_late;
    px::aholder::srec_t init_early;
    init_late.a = 1;
    init_early.a = 1;
  end
endmodule
