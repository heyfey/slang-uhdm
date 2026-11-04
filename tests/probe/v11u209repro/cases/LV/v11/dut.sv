// § tfItemInitLocalAtType209: a task with a body output port and initialized locals
module top;
  int r;
  task t;
    output int o;
    int x = 5;
    logic [7:0] y = 8'd1;
    o = x + y;
  endtask
  initial t(r);
endmodule
