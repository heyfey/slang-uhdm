// § classBoundedQueueStatic408
class c;
  localparam int P = 6;
  int q[$:P/2];
  int r[$:P+P];
  int s[$:(P)];
endclass
module top;
  c h;
  initial h = new;
endmodule
