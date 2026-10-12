// § escNameSpanSites295
module child(input logic \a.p , output logic b);
  assign b = \a.p ;
endmodule
module top(input logic [1:0] a, output logic [1:0] b);
  child u [1:0] (.\a.p (a), .b(b));
endmodule
