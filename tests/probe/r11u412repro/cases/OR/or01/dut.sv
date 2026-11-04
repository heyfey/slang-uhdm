// § oobScopedClsTdRetUnsup412
typedef real T;
class C;
    typedef int T;
    extern function T f();
    extern function int g();
    function T h(); return 2; endfunction
    extern function real f2();
endclass
function C::T C::f();
    return 1;
endfunction
function int C::g();
    return 3;
endfunction
function real C::f2();
    return 1.0;
endfunction
