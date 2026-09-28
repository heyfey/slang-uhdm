// § tfItemInitLocalAtType209: a task without parentheses
module top;
  int r;
  task t;
    int x = 5;
    byte y = 8'd1;
    r = x + y;
  endtask
  initial t;
endmodule
