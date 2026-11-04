module top(output logic [11:0] o);
  typedef struct packed { logic [19:0] hi; logic [11:0] f; } op_t;
  localparam op_t OP = '{hi:'0, f: 12'h800};
  assign o = OP.f;
endmodule
