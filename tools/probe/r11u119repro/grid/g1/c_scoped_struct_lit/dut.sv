package pkg;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } s_t;
endpackage
module top  (output logic [7:0] o);
  pkg::s_t a = 8'h12;
  assign o = a;
endmodule
