// § classBoundedQueueStatic408
class c;
  localparam int M = 5;
  byte q[$:M];
endclass
module top;
  c h;
  initial h = new;
endmodule
