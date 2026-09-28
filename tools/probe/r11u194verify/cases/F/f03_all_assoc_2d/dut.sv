// § foreachAssocLocalSharesDeclTs183 § foreachAssocLoopVarIdxTs183: a foreach over an all-associative two-dimensional local (string then int keys) and a mixed local (associative then fixed) in a package function
package p;
  function automatic int f();
    int m2[string][int];
    int mx[string][3];
    int n;
    foreach (m2[i, j]) n += m2[i][j];
    foreach (mx[a, b]) n += mx[a][b];
    return n;
  endfunction
endpackage
module top; endmodule
