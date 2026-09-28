// § classPropElemClassTsAtName196: a package-qualified element (pass 186's qualified route) and controls without a parameter list
package q;
  class pool #(type K = int, type V = int); endclass
  class plain; endclass
endpackage
package p;
  class db;
    q::pool#(int, int) a[$];
    q::plain b[$];
    q::pool c[$];
  endclass
endpackage
module top; endmodule
