// § bitSelMethodCallIdxSpan207: a method on a call result, on an array element, on a member of this and on a multi-line argument list as an index
package p;
class C;
  int m[int];
  C nx;
  C arr[2];
  function C self(); return this; endfunction
  function int gi(int a = 0); return a; endfunction
  function int f(C c);
    return m[c.self().gi(1)] + m[arr[0].gi(2)] + m[this.nx.gi(3)] + m[c.gi(
        4)] + m[c.nx.nx.gi()];
  endfunction
endclass
endpackage
module top; endmodule
