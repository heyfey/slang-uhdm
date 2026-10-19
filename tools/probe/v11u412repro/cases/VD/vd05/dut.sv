// § tfDeclOnlyBodyBegin412
module top;
  function void f(input int i);
    int x = i;
  endfunction
  task t;
    int a;
    logic b;
    real r;
  endtask
  interface_dummy d();
endmodule
module interface_dummy;
  task t;
    int a;
    ;
  endtask
endmodule
