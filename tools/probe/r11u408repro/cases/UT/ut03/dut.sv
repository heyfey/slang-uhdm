// § unitTaskNotListed408
function automatic int twice(int a);
  return 2 * a;
endfunction
module top;
  int x;
  initial x = twice(3);
endmodule
