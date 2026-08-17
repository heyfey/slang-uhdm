// g4 — NEGATIVE CONTROL #2: the same package variables and the same class, with
// NO import at all.  The arm is never entered; the whole design must be
// byte-identical before and after.
package p4;
  int a4 = 1;
  int b4 = a4;
endpackage
package q4;
  class c4;
    int own4;
  endclass
endpackage
module m4;
  q4::c4 h4;
endmodule
