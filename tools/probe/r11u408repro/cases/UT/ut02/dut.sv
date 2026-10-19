// § unitTaskNotListed408
task automatic show(input int a);
  $display(a);
endtask
module top;
  initial show(3);
endmodule
