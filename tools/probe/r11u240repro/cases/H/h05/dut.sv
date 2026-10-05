// § hoistPoolSourceOrder240: constructors of every class follow every method, across classes
package hp;
  class zz;
    int k;
    extern function new();
  endclass
  function zz::new();
    k = 1;
  endfunction
  class mm;
    int k;
    extern function int get();
    extern task run();
  endclass
  function int mm::get();
    return k;
  endfunction
  task mm::run();
    k++;
  endtask
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
