// § classPropElemClassTsAtName196: element class specializations with int-keyed and wildcard associative, 2-D fixed and bounded-queue dimensions
package p;
  class pool #(type K = int, type V = int); endclass
  class db;
    pool#(int, byte) m_int[int];
    pool#(byte, int) m_any[*];
    pool#(int, int) grid[2][3];
    pool#(string, bit) bq[$:4];
  endclass
endpackage
module top; endmodule
