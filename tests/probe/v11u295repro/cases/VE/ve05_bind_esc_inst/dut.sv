// § escNameSpanSites295
module chk(input logic a);
endmodule
module child(input logic a, output logic b);
  assign b = a;
endmodule
module top(input logic a, output logic b);
  child u (.a(a), .b(b));
endmodule
bind child chk \c.k (.a(a));
