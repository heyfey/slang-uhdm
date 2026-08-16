// NEGATIVE CONTROL 2: the same two packages and the same class, with NO import.
// Nothing is copied; the package's own listing is the only thing that exists.
package p5;
  class k5;
    int x5;
  endclass
  k5 m5 [string];
endpackage

package q5;
  class c5;
    int own5;
  endclass
endpackage

module top5;
  q5::c5 h5;
endmodule
