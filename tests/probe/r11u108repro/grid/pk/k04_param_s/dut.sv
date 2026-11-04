package p;
  localparam int N = 3;
  typedef logic [3:0] v_t;
  typedef logic [0:N-1] vn_t;
  typedef logic s_t;
endpackage
module sub #(parameter p::s_t M = '0) (output logic o);
  assign o = M;
endmodule
module dut (output logic o);
  sub #(.M(1'b1)) u (.o(o));
endmodule
