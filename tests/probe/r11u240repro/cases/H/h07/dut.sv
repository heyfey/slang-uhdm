// § hoistPoolSourceOrder240: a task body before a function body, several names in one body
package hp;
  class zt;
    int a, b;
    extern task t1();
  endclass
  task zt::t1();
    b = a;
    a++;
  endtask
  class at;
    int a, b;
    extern function int f1();
  endclass
  function int at::f1();
    return a + b;
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
