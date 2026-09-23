package p0;
  typedef logic [5:0] k_t;
endpackage
package p;
  typedef struct packed { p0::k_t key; logic [1:0] x; } s_t;
  localparam s_t D = 8'h5a;
endpackage
module dut (output logic [7:0] o);
  parameter p::s_t P = p::D;
  assign o = P;
endmodule
