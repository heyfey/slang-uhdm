// r10uvm173 arm B — TWO PACKAGES.  A call inside one package's DEF listing to
// ANOTHER package's function is the shape the law's gate deliberately does NOT
// claim (no golden in the corpus writes it), so this arm exists to record what
// golden does there and to prove the gate leaves it where it was.
package flintPkg;
  function automatic int unsigned emberCount(int unsigned v);
    return v + 11;
  endfunction
  task automatic emberTask(input int unsigned v, output int unsigned o);
    o = v + 12;
  endtask
endpackage

package tinderPkg;
  import flintPkg::*;

  // UNQUALIFIED call into the OTHER package (through the wildcard import).
  function automatic int unsigned wickBare(int unsigned v);
    return emberCount(v) + 1;
  endfunction

  // QUALIFIED call into the OTHER package.
  function automatic int unsigned wickQual(int unsigned v);
    return flintPkg::emberCount(v) + 2;
  endfunction

  // ...and a call to tinderPkg's OWN function, so both directions live in one
  // package listing.
  function automatic int unsigned wickHome(int unsigned v);
    return wickBare(v) + tinderPkg::wickQual(v);
  endfunction
endpackage

module tinder_top (output int unsigned z1, output int unsigned z2);
  import tinderPkg::*;
  int unsigned e1;
  initial flintPkg::emberTask(3, e1);
  assign z1 = wickHome(5);
  assign z2 = tinderPkg::wickBare(6) + e1;
endmodule
