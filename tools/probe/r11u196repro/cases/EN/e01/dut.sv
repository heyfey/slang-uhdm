// § classPropElemClassTsAtName196: associative and fixed-array properties of a parameterized element class (r11u194 U/u04, the UVM uvm_pool shape)
package p;
  class pool #(type K = int, type V = int); endclass
  class comp; endclass
  class db;
    static pool#(string, int) m_rsc[comp];
    pool#(int, byte) fx[2];
  endclass
endpackage
module top; endmodule
