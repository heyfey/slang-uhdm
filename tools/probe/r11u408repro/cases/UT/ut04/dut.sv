// § unitTaskNotListed408
function automatic int twice(int a);
  return 2 * a;
endfunction
task t2(output int o);
  o = 5;
endtask
module top;
  int x;
  initial x = twice(3);
endmodule
