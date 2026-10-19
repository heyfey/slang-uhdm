// § hierSelMacroBoundPretty405
`define HI 6
module top (output logic [6:0] o);
  typedef struct packed { logic [7:0] rs1_addr; logic v; } q_t;
  q_t q;
  assign q = '0;
  assign o = q.rs1_addr[`HI:0];
endmodule
