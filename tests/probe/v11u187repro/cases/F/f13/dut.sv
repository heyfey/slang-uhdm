// § foreachAssocLoopVarIdxTs183 (an int-keyed class property)
package p;
class c;
  int m[int];
  function int f();
    int n;
    foreach (m[k]) n += k;
    return n;
  endfunction
endclass
endpackage
module top; endmodule
