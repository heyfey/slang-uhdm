// § escNameSpanSites295
module child(input logic a, output logic b);
  assign b = a;
endmodule
module top(input logic a, output logic b);
  child \u.w (.*);
endmodule
