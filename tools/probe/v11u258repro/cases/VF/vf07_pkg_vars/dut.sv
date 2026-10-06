// § forMultiInitAssign258 (a package function writing the package's own variables unqualified)
package p; int pi, pj;
  function automatic int f(); int n = 0; for (pi = 0, pj = 1; pi < 3; pi++) n += pj; return n; endfunction
endpackage
module top(output int o); initial o = p::f(); endmodule
