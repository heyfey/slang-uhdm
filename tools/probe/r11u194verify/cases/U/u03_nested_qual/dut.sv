// § classPropElemQualTs186: a nested qualifier (a class inside a package class) and a parameterized qualified element class in fixed arrays of a module class
package q;
  class outer;
    class inner; endclass
  endclass
  class pc #(int W = 4); endclass
endpackage
module top;
  class c;
    q::outer::inner ni[2];
    q::pc#(8) pa[2];
    q::outer oa[3];
  endclass
endmodule
