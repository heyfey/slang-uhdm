// § escNameSpanSites295
module child(input logic a, output logic b);
  assign b = a;
endmodule
module top(input logic [1:0] a, output logic [1:0] b);
  for (genvar k = 0; k < 2; k++) begin : g
    child \u.k (.a(a[k]), .b(b[k]));
  end
endmodule
