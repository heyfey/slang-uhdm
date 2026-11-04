// § sysCallEmptyArgEndPrevTok441
module top;
  int a = 1, b = 2;
  task t;
    $write("x", a,
           ,
           , b);
  endtask
  initial t;
endmodule
