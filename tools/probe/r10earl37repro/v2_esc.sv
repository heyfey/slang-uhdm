// VERIFIER probe: ESCAPED IDENTIFIER containing a DOT as the base of a dotted
// port actual in a gen scope.  The gate reads raw TEXT for '.', and the
// ScopedName arm SPLITS the raw text on '.', so an escaped name whose spelling
// contains dots is the classic name-reading-gate trap the ops rules name.
package q40;
  typedef struct packed { logic rd; logic [7:0] addr; } req_t;
endpackage
module ch40 (input logic rd_i, input logic [7:0] addr_i, output logic ack_o);
  assign ack_o = rd_i & addr_i[0];
endmodule
module top40 (
  input  q40::req_t   \pin.i ,
  output logic [15:0] ack_o
);
  for (genvar b = 0; b < 2; b++) begin : gen_e
    ch40 i_esc (
      .rd_i(\pin.i .rd),
      .addr_i(\pin.i .addr),
      .ack_o(ack_o[b])
    );
  end
endmodule
