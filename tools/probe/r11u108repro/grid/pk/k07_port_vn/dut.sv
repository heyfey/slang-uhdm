package p;
  localparam int N = 3;
  typedef logic [3:0] v_t;
  typedef logic [0:N-1] vn_t;
  typedef logic s_t;
endpackage
module dut (input p::vn_t a, output logic [2:0] o);
  assign o = a;
endmodule
