// § classBoundedQueueStatic408
class c #(int D = 4);
  logic q[$:D-1];
endclass
module top;
  c h;
  initial h = new;
endmodule
