// The index typespec is a BUILT-IN scalar rather than `string`: the same arm,
// a different typespec class, so the law is not read off one kind.
package p5;
  int m5 [int];
endpackage

package q5;
  import p5::*;
  class c5;
    int own5;
  endclass
endpackage

module top5;
  q5::c5 h5;
endmodule
