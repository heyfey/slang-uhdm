// § classPropElemClassTsAtName196: an empty parameter list, named parameter assignments, and a two-dimension element
package p;
  class pool #(type K = int, type V = int); endclass
  class db;
    pool#() e[$];
    pool#(.K(byte), .V(int)) n[2];
    pool#(int, int) m[2][3];
  endclass
endpackage
module top; endmodule
