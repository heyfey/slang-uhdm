package p;
  localparam int N = 3;
  typedef logic [3:0] v_t;
  typedef logic [0:N-1] vn_t;
  typedef logic s_t;
endpackage
module dut (input logic [2:0] a, output logic [2:0] o);
  p::vn_t x;
  assign x = a;
  assign o = x;
endmodule
