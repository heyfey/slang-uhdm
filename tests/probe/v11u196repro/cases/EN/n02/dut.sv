// § classPropElemClassTsAtName196: a typedef of a specialization (control: IdentifierName), a local / rand / protected element, and a class in a module class
package p;
  class pool #(type K = int, type V = int); endclass
  typedef pool#(int, byte) pt;
  class db;
    pt a[$];
    local pool#(int, int) b[$];
    protected static pool#(byte, byte) c[string];
  endclass
endpackage
module top; endmodule
