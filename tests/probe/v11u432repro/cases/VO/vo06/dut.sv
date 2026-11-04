// § unitOobBodyRefChainName432
typedef struct packed { logic [3:0] f; } s_t;
class C;
extern function logic [3:0] f(s_t a);
endclass
function logic [3:0] C::f(s_t a);
s_t b;
b = a;
return b.f | a.f;
endfunction
