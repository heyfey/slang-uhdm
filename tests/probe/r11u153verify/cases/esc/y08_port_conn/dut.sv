// § escIdPpColumnShift146
module sub(input logic a, output logic b); assign b = a; endmodule
module top(input logic i, output logic o);
  logic \s$ ; assign \s$ = i;
  sub u(.a(\s$ ), .b(o));
endmodule
