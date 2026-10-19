// § oobScopedClsTdRetUnsup412
class C;
    typedef logic [3:0] V;
    typedef struct packed { logic a; } S;
    extern function V v();
    extern function S s();
    extern task t(V x);
endclass
function C::V C::v();
    return 4'h1;
endfunction
function C::S C::s();
    return '0;
endfunction
task C::t(V x);
endtask
module top; endmodule
