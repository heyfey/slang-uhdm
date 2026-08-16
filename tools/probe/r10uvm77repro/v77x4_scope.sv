// r10uvm77 VERIFIER ARM x4 — THE FULLNAME REGIME across ENCLOSING SCOPES.
//
// The law adds `joinRef(prefix, name)` where pristine emitted no fullname at
// all.  Arm c2 measured exactly two scopes (a function, and a module
// `initial`).  This arm asks whether that one join is right in the scopes the
// CORPUS actually uses: an IN-BODY class method, an OUT-OF-BODY class method,
// a PACKAGE function, a TASK, and inside a GENERATE block — the places this
// campaign has repeatedly found `prefix` machinery to differ.
package x4pkg;
  class x4c;
    int status;
    extern function int oob();
    function int inbody();
      process p;
      int r;
      p = process::self();
      r = int'(p.status);          // (1) IN-BODY class method
      return r;
    endfunction
    task tsk(output int r);
      process p;
      p = process::self();
      r = int'(p.status);          // (2) TASK body, expression position
    endtask
  endclass

  function int x4c::oob();
    process p;
    p = process::self();
    return int'(p.status);         // (3) OUT-OF-BODY class method
  endfunction

  function int pkgfn();
    process p;
    p = process::self();
    return int'(p.status);         // (4) PACKAGE function
  endfunction
endpackage

module top77x4;
  import x4pkg::*;
  int r;
  genvar g;
  generate
    for (g = 0; g < 2; g++) begin : gblk
      int gr;
      initial begin
        process gp;
        gp = process::self();
        gr = int'(gp.status);      // (5) GENERATE-block scope
      end
    end
  endgenerate
  initial begin
    x4c o;
    o = new();
    r = o.inbody() + o.oob() + pkgfn();
    $display("%0d", r);
  end
endmodule
