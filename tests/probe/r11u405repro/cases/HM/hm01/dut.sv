// § hierSelMacroBoundPretty405
`define AW 5
module top (input logic sel, output logic [4:0] o);
  typedef struct packed { logic [7:0] rs1_addr; logic v; } q_t;
  q_t q;
  assign q = '0;
  assign o = q.rs1_addr[`AW-1:0];
endmodule
