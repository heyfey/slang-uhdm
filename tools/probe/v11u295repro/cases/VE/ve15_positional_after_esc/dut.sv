// § escNameSpanSites295
module child(input logic a, output logic b);
  assign b = a;
endmodule
module top(input logic a, output logic b);
  wire \x.y = a; child \u.s (\x.y , b);
endmodule
