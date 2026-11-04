// § anonMemberTdLastWriter212 — control: a module-scope struct typedef, a variable of it continuously assigned, no anonymous struct
module dut(input logic [4:0] d, output logic o);
  typedef struct packed { logic [3:0] a; logic b; } in_t;
  in_t z;
  assign z = d;
  assign o = z.b;
endmodule
