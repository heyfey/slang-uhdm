// § foreachAssocLocalSharesDeclTs183 § assocPromotedBoundAtBracket183 (a typedef index; § foreachAssocLoopVarIdxTs183 registers the index, inert without its StmtEmit half)
package p;
typedef bit [3:0] k_t;
function automatic int f();
  int m[k_t];
  int n;
  foreach (m[i]) n = n + 1;
  return n;
endfunction
endpackage
module top; endmodule
