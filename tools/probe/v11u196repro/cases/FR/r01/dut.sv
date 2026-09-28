// § retPkgQualTdNoAlias196: qualified returns of a scalar-logic typedef, an int typedef and a typedef of a typedef
package P;
    typedef logic S1;
    typedef int I;
    typedef logic [3:0] S;
    typedef S S2;
endpackage
module top(output logic o1, output int o2, output logic [3:0] o3);
    function automatic P::S1 f1(input logic a); return a; endfunction
    function automatic P::I f2(input int a); return a; endfunction
    function automatic P::S2 f3(input logic [3:0] a); return a; endfunction
    assign o1 = f1(1'b1);
    assign o2 = f2(3);
    assign o3 = f3(4'h3);
endmodule
