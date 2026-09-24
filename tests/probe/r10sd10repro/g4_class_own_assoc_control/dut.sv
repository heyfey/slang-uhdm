// NEGATIVE CONTROL 1: the CLASS'S OWN associative array of a class type, with no
// import anywhere.  There is no copy, so this pass must not touch it.
package p4;
  class k4;
    int x4;
  endclass
  class c4;
    k4 own4 [string];
  endclass
endpackage

module top4;
  p4::c4 h4;
endmodule
