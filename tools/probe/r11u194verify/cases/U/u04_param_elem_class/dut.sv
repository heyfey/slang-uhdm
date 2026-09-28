// § classPropElemClassTsAtType183: a parameterized element class (with a parameter list) in associative and fixed-array properties of a package class (the UVM uvm_pool#(...) m_rsc[...] shape)
package p;
  class pool #(type K = int, type V = int); endclass
  class comp; endclass
  class db;
    static pool#(string, int) m_rsc[comp];
    pool#(int, byte) fx[2];
  endclass
endpackage
module top; endmodule
