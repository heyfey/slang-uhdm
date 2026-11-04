// § superMemberHierPath413
package pk;
  class P;
    int value;
  endclass
  class L extends P;
    int k;
    function void f();
      k = 2 * super.value;
    endfunction
  endclass
endpackage
module top;
  import pk::*;
  L l;
  initial begin l = new; l.f(); end
endmodule
