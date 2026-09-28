// § anonMemberTdLastWriter212 — r11u217 s11: a MODULE-scope struct typedef written as an anonymous-struct member and typing a module parameter and a localparam
module dut(input logic [4:0] d, output logic o);
  typedef struct packed { logic [3:0] a; logic b; } in_t;
  parameter in_t P = '{ a: 4'd3, b: 1'b1 };
  localparam in_t Q = '{ a: 4'd1, b: 1'b0 };
  struct packed { in_t m; } w;
  assign w = d;
  assign o = w.m.b ^ P.b ^ Q.b;
endmodule
