// r10uvm72 arm a2 — THE SITE axis and THE NEGATIVE CONTROLS, UVM-free.
//
// a1 fixes the caller's home at "inside the declaring package".  This arm moves
// the CALLER's home instead — $unit scope under a wildcard import (SimpleUVM's
// own `class env`), module scope, and a class nested in a module — and pins the
// cells that MUST NOT MOVE:
//
//   * an inherited name with NO package free function of that name  -> UNBOUND,
//     and it must STAY unbound (LAW C / § classCallNoLink12's t6 rule).
//   * a call to the caller's OWN class's method                     -> binds
//     the METHOD, and must keep binding it.
//   * an inherited name whose package twin is a TASK                -> the
//     § classCallNoLink12 arm has already committed to a func_call and must
//     NOT stamp a task into vpiFunction.
//   * a QUALIFIED call                                              -> its own
//     lookup, untouched.
package p2;

  function int fe(int v);                 // the package free function
    return v + 100;
  endfunction

  task tk(int v);                         // a package TASK twin (negative)
    $display("p2::tk %0d", v);
  endtask

  class shbase;
    function int fe(int v);               // shadows p2::fe
      return v + 1;
    endfunction
    function int lonely(int v);           // NO package twin of this name
      return v + 2;
    endfunction
    task tk(int v);                       // shadows p2::tk
      $display("shbase::tk %0d", v);
    endtask
    function int own(int v);
      return v + 3;
    endfunction
    function void base_calls_own();
      if (own(1)) $display("base_calls_own");   // SAME class -> binds own()
    endfunction
  endclass

  class inpkg extends shbase;
    function void c_shadowed();
      if (fe(1)) $display("c_shadowed");        // -> p2::fe
    endfunction
    function void c_lonely();
      if (lonely(2)) $display("c_lonely");      // NO package twin -> UNBOUND
    endfunction
    task c_taskname();
      tk(3);                                    // inherited TASK, package TASK
    endtask
    function void c_qual();
      if (p2::fe(4)) $display("c_qual");        // QUALIFIED
    endfunction
    function void c_own_inherited();
      if (own(5)) $display("c_own_inherited");  // inherited, no package twin
    endfunction
  endclass

endpackage

// ---- $unit scope under a WILDCARD IMPORT: SimpleUVM's `class env` shape
import p2::*;

class unitcls extends shbase;
  function void u_shadowed();
    if (fe(6)) $display("u_shadowed");          // wildcard-imported p2::fe
  endfunction
  function void u_lonely();
    if (lonely(7)) $display("u_lonely");        // still UNBOUND
  endfunction
  extern function void u_oob();
endclass

function void unitcls::u_oob();
  if (fe(8)) $display("u_oob");                 // $unit + out-of-body
endfunction

// ---- MODULE scope: a module-local free function shadowed the same way
module top;
  import p2::*;

  function int mfe(int v);                      // module-level free function
    return v + 200;
  endfunction

  class modbase;
    function int mfe(int v);                    // shadows the module's mfe
      return v + 1;
    endfunction
  endclass

  class modcls extends modbase;
    function void m_shadowed();
      if (mfe(9)) $display("m_shadowed");       // -> work@top.mfe
    endfunction
    function void m_pkgname();
      if (fe(10)) $display("m_pkgname");        // wildcard-imported p2::fe
    endfunction
  endclass

  unitcls uc;
  modcls mc;
  inpkg ip;
  initial begin
    uc = new(); uc.u_shadowed(); uc.u_lonely(); uc.u_oob();
    mc = new(); mc.m_shadowed(); mc.m_pkgname();
    ip = new(); ip.c_shadowed(); ip.c_lonely();
    ip.c_taskname(); ip.c_qual(); ip.c_own_inherited();
  end
endmodule
