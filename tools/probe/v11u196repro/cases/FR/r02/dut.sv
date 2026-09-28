// § retPkgQualTdNoAlias196: a qualified return in a package class method, in an interface function, and in a package function of the typedef's own package
package P;
    typedef logic [3:0] S;
    function automatic P::S own(input logic [3:0] a); return a; endfunction
    class C;
        function P::S get(); return 4'h1; endfunction
    endclass
endpackage
interface ifc;
    function automatic P::S fi(input logic [3:0] a); return a; endfunction
endinterface
module top(output logic [3:0] o);
    ifc u();
    assign o = P::own(4'h2);
endmodule
