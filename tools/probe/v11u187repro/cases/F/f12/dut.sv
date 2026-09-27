// § foreachAssocLoopVarIdxTs183 (a class-keyed local array in a class method)
package p;
class e; endclass
class c;
  function int f();
    bit m[e];
    int n;
    foreach (m[k]) n++;
    return n;
  endfunction
endclass
endpackage
module top; endmodule
