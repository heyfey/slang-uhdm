// § unitTaskNotListed408
task automatic inner(output int o);
  o = 2;
endtask
task automatic outer(output int o);
  inner(o);
endtask
module top;
  logic a;
endmodule
