// § wildcardConnRefSpan130
module leaf(input logic a, output logic y);
  assign y = !a;
endmodule
module mid(input logic a, output logic y);
  leaf l(.*);
endmodule
module top(input logic a, output logic y);
  mid m(.*);
endmodule
