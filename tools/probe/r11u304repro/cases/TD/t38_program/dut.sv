// § tfBodyTypedefForcesBegin304
program pr;
  int q;
  task t(int a);
    typedef bit [2:0] s_t;
    q = a;
  endtask
  initial t(1);
endprogram
module top; endmodule
