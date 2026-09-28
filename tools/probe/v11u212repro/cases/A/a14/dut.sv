// § anonMemberTdLastWriter212 — verifier: the typedef written in an anonymous struct inside a module that is instantiated from another file only
typedef struct packed { logic [3:0] a; logic b; } in_t;
module dut(input logic [4:0] d, output logic o);
  kid k(.d(d), .o(o));
endmodule
