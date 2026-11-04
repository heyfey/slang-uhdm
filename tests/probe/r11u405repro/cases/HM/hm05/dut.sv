// § hierSelMacroBoundPretty405
`define SEL(x) x.rs1_addr[3:0]
module top (output logic [3:0] o);
  typedef struct packed { logic [7:0] rs1_addr; logic v; } q_t;
  q_t q;
  assign q = '0;
  assign o = `SEL(q);
endmodule
