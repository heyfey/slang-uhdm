// § importCloneSharesHomeReturn218 — a class method returning an enum and one returning a logic vector, imported by a package and read in a module
package p;
  typedef enum logic [1:0] {X0, X1, X2} x_e;
  class c;
    function x_e pick(int i); return x_e'(i); endfunction
    function logic [7:0] wide(int i); return 8'(i); endfunction
  endclass
endpackage
package q;
  import p::*;
  class k extends c; int z; endclass
endpackage
module top;
  import q::*;
endmodule
