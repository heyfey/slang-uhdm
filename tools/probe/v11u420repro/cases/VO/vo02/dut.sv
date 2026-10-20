// § modOutOfBodyMethodIsModuleTf420
module top;
  class C;
    int x;
    extern task t(int a);
  endclass
  task C::t(int a);
    x = a;
  endtask
endmodule
