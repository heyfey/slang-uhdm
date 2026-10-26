// § genClsNoDefRangeSyntax436
package p;
class C #(parameter int N);
function logic [N-1:0] f(input logic [N:0] a);
logic [2*N-1:0] t;
return t[N-1:0];
endfunction
endclass
endpackage
