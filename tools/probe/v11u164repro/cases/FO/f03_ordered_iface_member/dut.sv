// § firstOrderedPathSel161 — an ordered list whose first actual is an interface member
interface itf;
  logic s, t;
endinterface
module ch(input a, input b, output c);
  assign c = a | b;
endmodule
module top(output o);
  itf i();
  ch u(i.s, i.t, o);
endmodule
