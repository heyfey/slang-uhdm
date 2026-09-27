// § assocBracketPkgOnly186 (a $unit class, a typedef key, an out-of-body method)
typedef int key_t;
class c;
  extern function void f();
endclass
function void c::f();
  int m[key_t];
  m[3] = 1;
endfunction
module top; endmodule
