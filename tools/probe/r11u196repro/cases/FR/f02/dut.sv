// § retPkgQualTdNoAlias196: a package-qualified return beside a qualified variable, formal and imported (unqualified) return
package P;
    typedef logic [3:0] S;
    typedef logic [7:0] B;
endpackage
module top(output logic [3:0] o, output logic [7:0] q);
    import P::B;
    P::S v;
    function automatic P::S f(P::S a); return a; endfunction
    function automatic B g(input logic [7:0] a); return a; endfunction
    assign o = f(v);
    assign q = g(8'h1);
endmodule
