// § retPkgQualTdNoAlias196: a qualified return where the package is also wildcard-imported, and a packed-array-of-typedef typedef
package P;
    typedef logic [3:0] S;
    typedef S [1:0] SS;
endpackage
module top(output logic [3:0] o, output logic [7:0] q);
    import P::*;
    function automatic P::S f(input logic [3:0] a); return a; endfunction
    function automatic P::SS g(input logic [7:0] a); return a; endfunction
    function automatic S h(input logic [3:0] a); return a; endfunction
    assign o = f(4'h1) ^ h(4'h2);
    assign q = g(8'h3);
endmodule
