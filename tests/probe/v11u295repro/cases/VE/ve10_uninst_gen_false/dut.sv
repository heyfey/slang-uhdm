// § escNameSpanSites295
module child(input logic a, output logic b);
  assign b = a;
endmodule
module top(input logic a, output logic b);
  if (0) begin : g
    child \u.z (.a(a), .b(b));
  end
  assign b = a;
endmodule
