// a3 — NO MACRO. A generic class body written ONCE, specialized twice with
// different type arguments: the same written location, two distinct actuals.
// This is the DANGER case for a purely location-keyed cache.
package pk3;
  class BoxG #(type Q = int, string Nm = "?");
    int g1;
  endclass
  class e1_red;  int r1; endclass
  class E2_blue; int b1; endclass
  class Wrap #(type P = int);
    typedef BoxG #(P,"wrapped") wid;
    P held;
  endclass
  class UseA; Wrap #(e1_red)  wa; endclass
  class UseB; Wrap #(E2_blue) wb; endclass
endpackage
