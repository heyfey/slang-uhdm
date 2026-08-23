// r10uvm115 / g115_a.sv — THE CONTEXT GRID for the builtin-class declaration.
// Purpose-built golden (Surelog is the reference).  A declaration whose written
// type is one of slang's `std` builtin classes (`process`, `semaphore`,
// `mailbox`) reached from every context the brief names: a package function
// body, a class method IN-BODY and OUT-OF-BODY, a module initial, a task, two
// vars in one body, and a class PROPERTY / a package variable / a module
// variable for contrast.
package p115;

  // (1) package function body local — THE CORPUS SHAPE (uvm_globals.svh:262)
  function void fn115();
    process p;
    p = process::self();
  endfunction

  // (1b) two vars in ONE body, and a second declaration of the same type
  function void fn115b();
    process p1;
    process p2;
    int q;
    p1 = process::self();
    p2 = p1;
  endfunction

  // (1c) a semaphore and a mailbox beside them
  function void fn115c();
    semaphore sem;
    mailbox mbx;
    process pr;
    sem = new(1);
    pr = process::self();
  endfunction

  // (1d) a TASK body local
  task tk115();
    process tp;
    tp = process::self();
  endtask

  // (2) class method IN-BODY, and a class PROPERTY
  class c115;
    process prop;
    function void meth();
      process mp;
      mp = process::self();
    endfunction
    extern function void oob();
  endclass

  // (2b) OUT-OF-BODY method body local
  function void c115::oob();
    process op;
    op = process::self();
  endfunction

  // (3) a PACKAGE-level variable
  process pkgvar;

endpackage

module top115;
  import p115::*;
  // (4) a MODULE-level variable
  process mvar;
  initial begin
    // (5) a module initial block local
    process ip;
    ip = process::self();
  end
  // (6) a plain always/initial with a semaphore
  semaphore msem;
endmodule
