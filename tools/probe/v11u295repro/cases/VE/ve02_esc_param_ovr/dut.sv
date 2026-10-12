// § escNameSpanSites295
module child #(parameter int W = 1)(input logic a, output logic b);
  assign b = a;
endmodule
module top(input logic a, output logic b);
  child #(.W(2)) \u.p (.a(a), .b(b));
endmodule
