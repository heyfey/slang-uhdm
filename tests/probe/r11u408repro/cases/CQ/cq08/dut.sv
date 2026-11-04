// § classBoundedQueueStatic408
class c;
  localparam int M = 5;
  shortint q[$:M+1];
  int u[$:2*M];
endclass
module top;
  c h;
  initial h = new;
endmodule
