// § escNameSpanSites295
module child(input logic \a.p , input logic \a.q , output logic b);
  assign b = \a.p & \a.q ;
endmodule
module top(input logic a, c, output logic b);
  child u (.\a.p (a), .\a.q (c), .b(b));
endmodule
