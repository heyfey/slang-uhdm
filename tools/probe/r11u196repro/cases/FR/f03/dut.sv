// § retPkgQualTdNoAlias196: a package function and a task returning a qualified typedef of another package, a struct and an enum typedef
package P;
    typedef logic [3:0] S;
    typedef struct packed { logic a; logic [2:0] b; } st_t;
    typedef enum logic [1:0] {A, B2} e_t;
endpackage
package Q;
    function automatic P::S pf(input logic [3:0] a); return a; endfunction
endpackage
module top(output logic [3:0] o, output P::st_t s, output P::e_t e);
    function automatic P::st_t fs(input logic x); return '{x, 3'd1}; endfunction
    function automatic P::e_t fe(input logic x); return x ? P::A : P::B2; endfunction
    assign o = Q::pf(4'h2);
    assign s = fs(1'b1);
    assign e = fe(1'b0);
endmodule
