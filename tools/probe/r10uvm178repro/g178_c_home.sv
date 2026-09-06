// r10uvm178 ARM C — THE PARAMETER-HOME DIMENSION.  MEASUREMENT ONLY.
// WHERE the parameter lives, against a constant reader position (`^=`):
//   own      — declared in the reading package itself
//   wild     — another package, pulled in with a WILDCARD import (the clone)
//   explicit — another package, pulled in with an EXPLICIT single import
//   scoped   — another package, read `::`-qualified with no import at all
//   renest   — a package that wildcard-imports the WILDCARD IMPORTER (a clone
//              of a clone), which is the deepest copy the corpus can build
//   module   — a MODULE function reading the imported parameter, the control
//              that must not move because its home is not a package at all
// The reader functions are named out of order and the numbers differ per cell
// so that agreement cannot come from the arm mirroring itself.

package Src178;
  parameter int src_poly178 = 32'h04c1_1db6;
  parameter int src_alt178  = 32'h1edc_6f41;
endpackage

package Own178;
  parameter int own_poly178 = 32'h741b_8cd7;
  function automatic int own_read178(input int a);
    int r;
    r = a;
    r ^= own_poly178;              // HOME own
    return r;
  endfunction
  function automatic int scoped_read178(input int a);
    int r;
    r = a;
    r ^= Src178::src_alt178;       // HOME scoped, no import
    return r;
  endfunction
endpackage

package Wild178;
  import Src178::*;
  function automatic int wild_read178(input int a);
    int r;
    r = a;
    r ^= src_poly178;              // HOME wildcard import (the CLONE)
    return r;
  endfunction
endpackage

package Expl178;
  import Src178::src_poly178;
  function automatic int expl_read178(input int a);
    int r;
    r = a;
    r ^= src_poly178;              // HOME explicit import
    return r;
  endfunction
endpackage

// Renest178 wildcard-imports the IMPORTER, so it carries a CLONE OF A CLONE of
// `wild_read178` (whose body reads Src178's parameter) while its OWN parameter
// is at home here.  Wildcard imports are not transitive, so `src_poly178` is
// NOT visible in this package's own source — only inside the cloned body.
package Renest178;
  import Wild178::*;
  parameter int renest_poly178 = 32'h2222_3333;
  function automatic int renest_read178(input int a);
    int r;
    r = a;
    r ^= renest_poly178;           // own parameter inside a CLONE CARRIER
    return r;
  endfunction
endpackage

module m178c (input logic clk, output int c1, c2, c3, c4, c5, c6);
  import Own178::*;
  import Wild178::*;
  import Expl178::*;
  import Renest178::*;
  function automatic int mod_read178(input int a);
    int r;
    r = a;
    r ^= src_poly178;              // HOME module function, the control
    return r;
  endfunction
  assign c1 = own_read178(32'd101);
  assign c2 = mod_read178(32'd202);
  assign c3 = scoped_read178(32'd303);
  assign c4 = wild_read178(32'd404);
  assign c5 = expl_read178(32'd505);
  assign c6 = renest_read178(32'd606);
endmodule
