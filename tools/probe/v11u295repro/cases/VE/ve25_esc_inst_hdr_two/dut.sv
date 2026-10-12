// § escNameSpanSites295
module child(input logic a, output logic b);
  assign b = a;
endmodule
module top(input logic a, output logic b, c);
  child \u.a (.a(a), .b(b)); child \u.b (.a(a), .b(c));
endmodule
