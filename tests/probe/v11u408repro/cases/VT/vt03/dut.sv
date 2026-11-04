// § unitTaskNotListed408
package pk;
  task automatic pt(output int o);
    o = 1;
  endtask
endpackage
task automatic ut(output int o);
  o = 3;
endtask
module top;
  int x;
  initial pk::pt(x);
endmodule
