// § tfArgScalarTdWriter223 § importCloneSharesHomeReturn218 — an out-of-body class method whose formals and return are scalar typedefs, cloned by two importing packages
package p1;
  typedef int     FILE_T;
  typedef byte    B_T;
  class c;
    extern function FILE_T open(FILE_T f, B_T b);
    extern task put(B_T b);
  endclass
  function FILE_T c::open(FILE_T f, B_T b); return f + b; endfunction
  task c::put(B_T b); endtask
endpackage
package p2; import p1::*; endpackage
package p3; import p1::*; endpackage
module top(output int o);
  import p2::*;
  import p3::*;
  assign o = 1;
endmodule
