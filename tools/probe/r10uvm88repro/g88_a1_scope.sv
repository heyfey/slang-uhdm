// r10uvm88 arm a1 — WHICH SCOPE binds a reference to a PACKAGE-SCOPE variable?
//
// ONE golden, read on the whole matrix the brief names:
//   (a) a class method written INSIDE the class body      <- the corpus head
//   (b) the same class's OUT-OF-BODY method
//   (c) a package-scope function
//   (d) a module that imports the package (task + initial)
//   (e) another package (its own class body + its own function)
//   (f) $unit / compilation-unit scope
// crossed with  const string / const int / plain (non-const) variable, and with
// a CLASS-SCOPE static referenced the same ways (the control that says "package
// scope", not "static storage", is the axis).
package p88;
  const string  cstr88 = "CS";      // the corpus shape (uvm_pkg::s_connection_*)
  const int     cint88 = 7;         // the corpus shape (UVM_UNBOUNDED_CONNECTIONS)
  string        pstr88 = "PS";      // NON-const, same position
  int           pint88 = 9;         // NON-const, same position

  class c88;
    static string sstat88 = "SS";   // CLASS-scope static: the control axis
    string m;
    // (a) IN-BODY method reading all four package variables
    function void inb88();
      m = cstr88;
      m = pstr88;
      m = $sformatf("%0d%0d", cint88, pint88);
      m = sstat88;
    endfunction
    // (b) the OUT-OF-BODY half, declared here, defined after endclass
    extern function void oob88();
    extern task oobt88();
  endclass

  function void c88::oob88();
    m = cstr88;
    m = pstr88;
    m = $sformatf("%0d%0d", cint88, pint88);
    m = sstat88;
  endfunction

  task c88::oobt88();
    m = cstr88;
    m = pstr88;
  endtask

  // (c) a PACKAGE-scope function
  function string pf88();
    return {cstr88, pstr88};
  endfunction

  // a package-scope variable whose INITIALIZER reads another package variable
  string pinit88 = cstr88;
endpackage

// (e) another package: imports p88, has its own class body + own function
package q88;
  import p88::*;
  class d88;
    string m;
    function void qinb88();      // in-body, reading the IMPORTED package's vars
      m = cstr88;
      m = pstr88;
    endfunction
    extern function void qoob88();
  endclass
  function void d88::qoob88();   // out-of-body, same reads
    m = cstr88;
    m = pstr88;
  endfunction
  function string qf88();
    return {cstr88, pstr88};
  endfunction
endpackage

// (f) $unit / compilation-unit scope
import p88::*;
string u88 = cstr88;
class e88;                        // a $unit class, in-body method
  string m;
  function void uinb88();
    m = cstr88;
    m = pstr88;
  endfunction
endclass

// (d) a module importing the package
module top88;
  import p88::*;
  import q88::*;
  string mv88;
  p88::c88 h88;
  initial begin
    mv88 = cstr88;
    mv88 = pstr88;
  end
  task mt88();
    mv88 = cstr88;
    mv88 = pstr88;
    mv88 = p88::cstr88;           // WRITTEN QUALIFIED, same target
  endtask
  // a module-scope CLASS with an in-body method (class not in a package)
  class f88;
    string m;
    function void minb88();
      m = cstr88;
      m = pstr88;
    endfunction
  endclass
endmodule
