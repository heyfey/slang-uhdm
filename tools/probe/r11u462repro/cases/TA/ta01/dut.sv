// § clsMethodOwnAutomatic462
package p;
  class C;
    task automatic t();
      int k;
      k = 1;
    endtask
    function automatic int f(int a);
      return a + 1;
    endfunction
    task u();
    endtask
    function int g();
      return 2;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  C c;
endmodule
