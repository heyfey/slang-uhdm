// § tfDeclOnlyBodyBegin412
class C;
  task t;
    static int a;
    int b;
  endtask
  function void f();
    int a, b;
  endfunction
  extern task e();
endclass
task C::e();
  int x;
  int y;
endtask
module top;
  C c;
endmodule
