package p;
  localparam int N = 3;
  typedef logic [3:0] v_t;
  typedef logic [0:N-1] vn_t;
  typedef logic s_t;
  typedef v_t [1:0] a_t;
  typedef struct packed { a_t [0:1] h; logic c; } sa_t;
endpackage
module dut (output logic [16:0] o);
  localparam p::sa_t P = '0;
  assign o = P;
endmodule
