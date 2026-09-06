// r10uvm173 arm C — THE HOMES.  The same discriminator read from every place
// a package-internal call can be written: a free function, a task, an IN-CLASS
// method, an OUT-OF-BODY class method (the shape uvm_pkg's DEF listing is made
// of), a class-property initializer, and a package-scope variable initializer.
// Recursion and a self-call are included because a def-listing body that calls
// ITSELF is the one cell where the two twins are the same source function.
package Marlowe_pkg;

  function automatic int unsigned rungOf(int unsigned d);
    return d * 3;
  endfunction

  // SELF-RECURSIVE: the callee is this very function, so the twin choice is
  // visible without a second name.
  function automatic int unsigned spiral(int unsigned d);
    if (d == 0)
      return 1;
    return spiral(d - 1) + rungOf(d);
  endfunction

  task automatic hoistTask(input int unsigned d, output int unsigned o);
    o = rungOf(d) + spiral(2);
  endtask

  class Gantry;
    int unsigned base;
    // A CLASS-PROPERTY INITIALIZER call (drained late in our emitter).
    int unsigned seeded = rungOf(2);
    extern function int unsigned outOfBody(int unsigned d);
    function new();
      base = rungOf(1);
    endfunction
    function int unsigned inBody(int unsigned d);
      return rungOf(d) + Marlowe_pkg::rungOf(d);
    endfunction
  endclass

  // OUT-OF-BODY definition: Surelog lists this one directly under the package
  // in the DEF view, which is exactly uvm_pkg's shape.
  function int unsigned Gantry::outOfBody(int unsigned d);
    return rungOf(d) + spiral(d) + Marlowe_pkg::rungOf(d);
  endfunction

  // A PACKAGE-SCOPE VARIABLE INITIALIZER call.
  int unsigned prewound = rungOf(4);

endpackage

module marlowe_top (output int unsigned w1, output int unsigned w2);
  import Marlowe_pkg::*;
  Gantry g;
  int unsigned t1;
  initial begin
    g = new();
    hoistTask(3, t1);
  end
  assign w1 = spiral(3) + prewound;
  assign w2 = Marlowe_pkg::rungOf(9) + t1;
endmodule
