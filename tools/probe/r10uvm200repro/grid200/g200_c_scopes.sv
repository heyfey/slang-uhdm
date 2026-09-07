// r10uvm200 grid arm C — CLASS scopes: an in-class method, an out-of-body
// method, a constructor and a nested class, all inside the clone.
package pa200c;
  parameter WD = 9;
  class C200;
    logic [WD:0] p;
    extern function logic [WD:0] m1(input logic [WD:0] a);
    function logic [WD:0] m2(input logic [WD:0] b);
      m2 = b;
    endfunction
    function new(input logic [WD:0] c);
      p = c;
    endfunction
    class N200;
      function logic [WD:0] n1(input logic [WD:0] d);
        n1 = d;
      endfunction
    endclass
  endclass
  function logic [WD:0] C200::m1(input logic [WD:0] a);
    logic [WD:0] mloc;
    mloc = a;
    m1 = mloc;
  endfunction
endpackage

package pb200c;
  import pa200c::*;
endpackage

module top200c;
  import pa200c::*;
  initial $display(WD);
endmodule
