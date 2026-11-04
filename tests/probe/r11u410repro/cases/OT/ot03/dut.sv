// § oobUnitClsTdUnsupported410
module test;
  class myclass;
    typedef int myint;
    extern task tsk(myint a, output myint b);
  endclass
  task myclass::tsk(myint a, output myint b); b = a; endtask
endmodule
