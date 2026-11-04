// § strLitContLineSpan220
module sub #(parameter logic [63:0] P = "ab\
cd") (output logic [63:0] o);
  assign o = P;
endmodule
module mid(output logic [63:0] o);
  sub u(.o(o));
endmodule
module top(output logic [63:0] o, output logic [63:0] q);
  mid m(.o(o));
  sub v(.o(q));
endmodule
