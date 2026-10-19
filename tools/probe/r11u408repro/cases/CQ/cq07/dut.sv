// § classBoundedQueueStatic408
class c;
  int q[$:3];
endclass
module top;
  c h;
  initial begin h = new; h.q.push_back(1); end
endmodule
