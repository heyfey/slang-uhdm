// a1 — ONE macro line expanded three times with DIFFERENT type arguments.
// Does the type-parameter ACTUAL collapse onto the FIRST expansion?
package pk1;
  class BoxA #(type Q = int, string Nm = "?");
    int q1;
  endclass
`define mk_a(X) typedef BoxA #(X,`"X`") tid;
  class alpha7;   `mk_a(alpha7)
  endclass
  class Bravo2;   `mk_a(Bravo2)
  endclass
  class charlie9; `mk_a(charlie9)
  endclass
endpackage
