// § classBoundedQueueStatic408
class c #(int D = 2);
  int q[$:D];
endclass
module top;
  c #(5) h;
  initial h = new;
endmodule
