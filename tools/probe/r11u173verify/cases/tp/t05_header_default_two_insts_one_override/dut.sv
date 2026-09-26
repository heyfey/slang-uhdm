// § tpAnonStructLastParamUser167 § tpAnonStructCopySpanAtKeyword167 — a header type parameter's struct default, one instance overrides the value
module sub #(parameter type T = struct packed { logic [2:0] a; logic [2:0] c; }, parameter T P = '{a: 3'd1, c: 3'd2}) (output logic [2:0] o);
  assign o = P.a ^ P.c;
endmodule
module top(output logic [2:0] o1, output logic [2:0] o2);
  sub u0(.o(o1));
  sub #(.P('{a: 3'd4, c: 3'd5})) u1(.o(o2));
endmodule
