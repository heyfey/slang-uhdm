// § tfDeclOnlyBodyBegin412
package pk;
  function int f();
    int a;
    int b;
  endfunction
  task t;
    int a = 1;
    int b;
  endtask
endpackage
module top;
  import pk::*;
endmodule
