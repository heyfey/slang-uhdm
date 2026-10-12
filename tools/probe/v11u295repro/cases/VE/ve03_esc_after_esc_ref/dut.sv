// § escNameSpanSites295
module child(input logic a, output logic b);
  assign b = a;
endmodule
module top(input logic a, output logic b);
  wire \w.a ; assign \w.a = a; child \u.q (.a(\w.a ), .b(b));
endmodule
