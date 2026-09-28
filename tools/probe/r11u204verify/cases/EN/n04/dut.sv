// § classPropElemClassTsAtName196: an element specialization whose parameter list spans two lines and holds a typedef and a nested specialization, a class-typed parameter default
package p;
  typedef logic [3:0] nib_t;
  class pool #(type K = int, type V = int); endclass
  class db;
    pool#(nib_t,
          pool#(int, int)) twoline[int];
    pool#(p::nib_t, int) qual[$];
  endclass
endpackage
module top; endmodule
