// § tfDeclOnlyBodyBegin412
module top;
  task t1;
    int a, b;
  endtask
  task t2;
    input int i;
    int a;
    int b;
  endtask
  task automatic t3();
    logic [3:0] x;
  endtask
endmodule
