// § classPropElemClassTsAtName196: queue and dynamic-array properties, a spaced parameter list
package p;
  class pool #(type K = int, type V = int); endclass
  class db;
    pool #( int , byte ) q[$];
    pool#(byte, int) d[];
  endclass
endpackage
module top; endmodule
