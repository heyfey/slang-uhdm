// § tfArgScalarTdWriter223 § importCloneSharesHomeReturn218 — a class method whose formals AND return are scalar typedefs, cloned by an importing package
package p;
  typedef int     FILE_T;
  typedef bit [3:0] NIB_T;
  class c;
    function FILE_T open(FILE_T f, NIB_T n);
      return f + n;
    endfunction
  endclass
endpackage
package q;
  import p::*;
  class d extends c; int z; endclass
endpackage
module top;
  import q::*;
endmodule
