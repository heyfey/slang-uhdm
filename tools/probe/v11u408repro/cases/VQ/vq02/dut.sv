// § classBoundedQueueStatic408
class c;
  localparam bit [7:0] P = 3;
  int q[$:P];
endclass
module top;
  c h;
  initial h = new;
endmodule
