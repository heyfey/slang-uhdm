// class_typespec NAMING of a class-typed LOCAL, both directions.
// UVM says: a package-level task's local is UNNAMED (uvm_globals::run_test
// `uvm_root top;`) while an OUT-OF-BODY class method's local is NAMED
// (uvm_component::m_set_cl_verb `uvm_cmdline_processor clp;`).  The committed
// rule says the opposite.  Pin every axis: declaration ORDER, inline vs
// out-of-body, package vs module, formal vs local, bare vs scoped name.
package other;
  class Oth;
    int o;
  endclass
endpackage

package pk;
  import other::*;
  typedef class Late;

  class Early;
    int e;
  endclass

  // A: package function, class declared BEFORE it
  function void fEarly();
    Early a;
    a = new();
  endfunction

  // B: package function, class declared AFTER it (forward typedef only)
  function void fLate();
    Late b;
    b = new();
  endfunction

  // H: package function FORMAL of class type
  function void fArg(Early h);
    h = null;
  endfunction

  // I: package function local named with a SCOPED name
  function void fScoped();
    other::Oth i0;
    i0 = new();
  endfunction

  // J: package-level TASK local (run_test's shape) + imported class
  task tLocal();
    Early j;
    Oth k;
    j = new();
    k = new();
  endtask

  class Holder;
    Early p;                       // C: class PROPERTY
    // D: INLINE class method local
    function void mInline();
      Early c;
      c = new();
    endfunction
    // E: out-of-body method, declared here
    extern function void mOut();
    // F: class-method FORMAL
    function void mArg(Early g);
      g = null;
    endfunction
  endclass

  // E body: out-of-body definition, textually in the PACKAGE
  function void Holder::mOut();
    Early d;
    Late e2;
    d = new();
    e2 = new();
  endfunction

  class Late;
    int l;
  endclass
endpackage

module top;
  import pk::*;
  // G: module function local
  function void fMod();
    pk::Early m;
    m = new();
  endfunction
  initial;
endmodule
