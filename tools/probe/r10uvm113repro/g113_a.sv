// r10uvm113 / g113_a.sv — THE CONTEXT GRID for § classOwnLateMethodBindsPkgFn113.
// Purpose-built golden (Surelog is the reference).  The SAME collision — a free
// subroutine of the home package whose name is ALSO a method declared BELOW the
// caller — reached from every context the brief names: a package-variable
// initializer, a package function body, a class method IN-BODY, OUT-OF-BODY and
// STATIC, a constraint, a module, an importing package, a SECOND importer, and
// $unit.  Every arm also carries the no-collision twin so an arm that agrees for
// the wrong reason shows up.
package home;
  function int rho(int x); return x + 1; endfunction
  function int sigma(int x); return x + 2; endfunction
  task tau(input int x); endtask

  // (1) package-variable initializer
  int pkgVarInit = rho(7);

  // (2) package function body (no class in sight)
  function int pkgBody(); return rho(8) + sigma(9); endfunction

  class Cin;
    // (3) class method IN-BODY, caller ABOVE the collision
    function int above(); return rho(1); endfunction
    function int rho(int x); return x + 100; endfunction
    // caller BELOW the collision
    function int below(); return rho(2); endfunction
    // (3b) STATIC method, caller ABOVE its own `sigma`
    static function int stat(); return sigma(3); endfunction
    static function int sigma(int x); return x + 200; endfunction
    // a TASK collision, caller above (a task caller: a function may not call
    // a task)
    task callsTau(); tau(4); endtask
    task tau(input int x); endtask
  endclass

  class Coob;
    extern function int oob();
    extern static function int oobStat();
    function int rho(int x); return x + 300; endfunction
    static function int sigma(int x); return x + 400; endfunction
  endclass
  // (4) OUT-OF-BODY definitions, compiled in the PACKAGE's scope
  function int Coob::oob();      return rho(5);   endfunction
  function int Coob::oobStat();  return sigma(6); endfunction

  // (5) a constraint whose expression calls the colliding name
  class Ccon;
    rand int v;
    constraint c_v { v == rho(2); }
    function int rho(int x); return x + 500; endfunction
  endclass
endpackage

// (6) an IMPORTING package: the same collision, reached through a wildcard import
package imp1;
  import home::*;
  class Cimp;
    function int above(); return rho(11); endfunction
    function int rho(int x); return x + 600; endfunction
  endclass
endpackage

// (7) a SECOND importer, explicit import this time, and a different order
package imp2;
  import home::sigma;
  class Cimp2;
    function int first(); return sigma(12); endfunction
    function int second(); return sigma(13); endfunction
    function int sigma(int x); return x + 700; endfunction
  endclass
endpackage

// (8) $unit scope: a class declared at compilation-unit scope under a wildcard
//     import — the walk lands on a CompilationUnit that declares nothing.
import home::*;
class Cunit;
  function int above(); return rho(21); endfunction
  function int rho(int x); return x + 800; endfunction
endclass

// (9) a MODULE with its own free function and a class inside it
module tb_a;
  import home::*;
  function int omega(int x); return x + 3; endfunction
  class Cmod;
    function int above(); return omega(31); endfunction
    function int omega(int x); return x + 900; endfunction
  endclass
  Cin ci; Coob co; Ccon cc; Cunit cu; Cmod cm;
  imp1::Cimp c1;
  imp2::Cimp2 c2;
  initial begin
    ci = new(); co = new(); cc = new(); c1 = new(); c2 = new();
    cu = new(); cm = new();
  end
endmodule
