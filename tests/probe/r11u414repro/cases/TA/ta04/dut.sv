// § clsTdArgAliasTwin414
class myclass;
typedef int i_t;
extern function void f(i_t a);
extern function i_t g(i_t a, i_t b);
endclass
function void myclass::f(i_t a); endfunction
function myclass::i_t myclass::g(i_t a, i_t b); return a; endfunction
module test;
endmodule
