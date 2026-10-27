// § pkgSubLoopVarReadBindsDecl445
package pk;
function automatic int f(int x); int q[$]; int r[$]; r = q.find(x) with (x > 1); return r.size(); endfunction
endpackage
module top; int y = pk::f(1); endmodule
