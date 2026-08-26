// r10uvm153 arm A — THE MECHANISM.  What does an OUT-OF-BODY package-scope
// method's BARE reference bind when the package's Variables() listing holds a
// name that matches?  LHS is always golden (Surelog); ours is the RHS.
//
// The head (uvm_pkg.sv:38789 `clp = uvm_cmdline_processor::get_inst();` inside
// `uvm_root::new()`) is a CLASS PROPERTY reference that golden binds to the
// package copy of a DIFFERENT class's constructor local.  Every cell here is
// named for what it is testing.
package pa153;

  int a_pkgv;                      // a REAL package variable
  string a_pkgs;

  class Ha153;                     // the donor: its out-of-body constructor's
    extern function new(int q);    // locals are collected as PACKAGE data
  endclass                         // declarations (CompilePackage.cpp:123)

  function Ha153::new(int q);
    int a_body;                    // body-level ctor local  -> package copy
    begin
      int a_nest;                  // nested-begin ctor local -> package copy
      a_nest = q;
      a_body = a_nest;
    end
  endfunction

  class Ca153;
    int a_prop;                    // collides with NOTHING in the package
    int a_pkgv;                    // collides with a REAL package variable
    int a_body;                    // collides with a HOISTED body local
    int a_nest;                    // collides with a HOISTED nested local
    extern function void ma153(int p);
    extern task ta153(int p);
    extern function new(int p);
    function void inbody153(int p);   // IN-BODY: no vpiInstance (§ 88)
      a_prop = p;
      a_pkgv = p;
      a_nest = p;
    endfunction
  endclass

  // OUT-OF-BODY ordinary function
  function void Ca153::ma153(int p);
    a_prop = p;                    // bare?
    a_pkgv = p;                    // package variable of that name
    a_body = p;                    // hoisted body local of that name
    a_nest = p;                    // hoisted nested local of that name
    a_pkgs = "x";                  // a package variable, no property
  endfunction

  // OUT-OF-BODY task
  task Ca153::ta153(int p);
    a_prop = p;
    a_pkgv = p;
    a_nest = p;
  endtask

  // OUT-OF-BODY constructor WITH a real port list (nothing is eaten)
  function Ca153::new(int p);
    a_prop = p;
    a_pkgv = p;
    a_nest = p;
  endfunction

  // A package FREE function: no class properties at all, the § 81 baseline.
  function int fa153(int a_pkgv);
    fa153 = a_pkgv;                // a FORMAL that collides (§ 81)
  endfunction

endpackage

module ma153_top;
  initial begin
    int u;
    u = pa153::fa153(1);
  end
endmodule
