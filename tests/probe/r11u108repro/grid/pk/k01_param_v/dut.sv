package p;
  localparam int N = 3;
  typedef logic [3:0] v_t;
  typedef logic [0:N-1] vn_t;
  typedef logic s_t;
endpackage
module sub #(parameter p::v_t M = '0) (output logic [3:0] o);
  assign o = M;
endmodule
module dut (output logic [3:0] o);
  sub #(.M(4'h5)) u (.o(o));
endmodule
