// § wildcardConnRefSpan130
module leaf(input logic a, input logic b, output logic y);
  assign y = a ^ b;
endmodule
module mid(input logic a, input logic b, output logic y);
  leaf l(.*);
endmodule
module top(input logic a, input logic b, output logic [1:0] y);
  for (genvar i = 0; i < 2; i++) begin : g
    logic yy;
    mid m(.a(a), .b(b), .y(yy));
    assign y[i] = yy;
  end
endmodule
