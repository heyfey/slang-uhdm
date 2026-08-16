// NEGATIVE CONTROL 2: the same two packages and the same class, with NO import.
package p4;
  class k4;
    int x4;
  endclass
  k4 m4 [string];
endpackage

package q4;
  class c4;
    int own4;
  endclass
endpackage

module top4;
  q4::c4 h4;
endmodule
