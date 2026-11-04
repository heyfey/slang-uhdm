// § classPropElemClassTsAtName196: a nested specialization as the element and a value parameter
package p;
  class pool #(type K = int, type V = int); endclass
  class vec #(int N = 2); endclass
  class db;
    pool#(pool#(int, int), int) nest[$];
    vec#(4) vs[3];
  endclass
endpackage
module top; endmodule
