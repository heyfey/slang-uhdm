package p;
  typedef logic [7:0] k_t;
  typedef union packed { k_t a; logic [7:0] b; } u_t;
  localparam u_t D = 8'h33;
endpackage
module dut (output logic [7:0] o);
  parameter p::u_t P = p::D;
  assign o = P;
endmodule
