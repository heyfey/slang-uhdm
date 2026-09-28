// § classPropElemClassTsAtName196: multi-line parameter list, macro-written element type
`define POOL(k,v) pool#(k, v)
package p;
  class pool #(type K = int, type V = int); endclass
  class db;
    pool#(string,
          int) ml[string];
    `POOL(int, int) mm[$];
  endclass
endpackage
module top; endmodule
