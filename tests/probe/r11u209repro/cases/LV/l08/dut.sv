// § tfItemInitLocalAtType209: a task without parentheses whose body declares an input
module top;
  int r;
  task t;
    input int a;
    int x = 5;
    byte y = 8'd1;
    r = a + x + y;
  endtask
  initial t(2);
endmodule
