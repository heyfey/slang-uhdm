// § oobScopedClsTdRetUnsup412
package pk;
class C;
    typedef int T;
    typedef logic [3:0] V;
    extern function T f();
    extern function V v();
endclass
function C::T C::f();
    return 1;
endfunction
function C::V C::v();
    return 4'h1;
endfunction
endpackage
module top; endmodule
