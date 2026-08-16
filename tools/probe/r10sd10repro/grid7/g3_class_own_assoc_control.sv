// NEGATIVE CONTROL 1: the CLASS'S OWN associative array, no import at all.
// Whatever golden does here, this pass must not change it.
package p3;
  class k3;
    int x3;
  endclass
  class c3;
    k3 own3 [string];
  endclass
endpackage

module top3;
  p3::c3 h3;
endmodule
