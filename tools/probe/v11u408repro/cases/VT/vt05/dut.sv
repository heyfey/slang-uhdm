// § unitTaskNotListed408
task automatic ut(output int o);
  o = 3;
endtask
class C;
  task run(); int y; ut(y); endtask
endclass
module top;
  C h;
  initial h = new;
endmodule
