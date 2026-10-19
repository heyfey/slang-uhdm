// § pkgTfMacroDefAtExpansion403
`define MKF(n) function int n(); return 1; endfunction
package p;
`MKF(a)
function int b(); return 2; endfunction
`MKF(c)
task t(); endtask
endpackage
module top; endmodule
