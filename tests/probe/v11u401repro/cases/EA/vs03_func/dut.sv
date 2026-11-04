// § sysCallEmptyArgIsIntZero401
module top;
  int a;
  function void f(); $display("v", , a); endfunction
  initial f();
endmodule
