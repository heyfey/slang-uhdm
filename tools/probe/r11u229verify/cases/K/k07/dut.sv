// § strLitContOwnerEnd224 (a logical or of two comparisons, the last operand a continued literal)
module top(input string s, output logic b);
  assign b = s == "x" || s == "ab \
cd";
endmodule
