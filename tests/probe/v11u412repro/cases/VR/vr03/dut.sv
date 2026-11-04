// § oobScopedClsTdRetUnsup412
class C;
  typedef int T;
  typedef logic [7:0] B;
  extern function T f();
  extern function B g();
endclass
function C::T C::f(); return 1; endfunction
function C::B C::g(); return 8'h1; endfunction
module top;
  C c;
endmodule
