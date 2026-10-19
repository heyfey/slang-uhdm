// § unitTaskNotListed408
task automatic ut(input int a, output int o);
  o = a + 1;
endtask
module top;
  int x;
  always @* ut(1, x);
endmodule
