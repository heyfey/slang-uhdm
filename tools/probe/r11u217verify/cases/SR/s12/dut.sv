// § anonMemberTdLastWriter212 — r11u217 s12: a $unit struct typedef written as an anonymous-struct member in one module and typing a PARAMETER of a child module overridden by the parent
typedef struct packed { logic [3:0] a; logic b; } in_t;
module ch #(parameter in_t P = '0) (output logic o);
  assign o = P.b;
endmodule
module dut(input logic [4:0] d, output logic o, output logic q);
  struct packed { in_t m; } w;
  assign w = d;
  assign o = w.m.b;
  ch #(.P('{ a: 4'd2, b: 1'b1 })) u (.o(q));
endmodule
