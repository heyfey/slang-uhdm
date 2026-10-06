// § forMultiInitAssign258 (an element of a class-property queue, then a plain property)
package p;
  class c;
    int q[$]; int i;
    function int f(); int n; q.push_back(0); for (q[0] = 0, i = 0; i < 3; i++) n += q[0]; return n; endfunction
  endclass
endpackage
module top; endmodule
