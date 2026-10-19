// § classBoundedQueueStatic408
class c #(int P = 3);
  int q[$:P];
endclass
module top;
  c h;
  initial h = new;
endmodule
