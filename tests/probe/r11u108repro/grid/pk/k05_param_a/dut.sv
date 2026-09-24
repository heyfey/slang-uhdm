package p;
  localparam int N = 3;
  typedef logic [3:0] v_t;
  typedef logic [0:N-1] vn_t;
  typedef logic s_t;
  typedef v_t [1:0] a_t;
endpackage
module sub #(parameter p::a_t M = '0) (output logic [7:0] o);
  assign o = M;
endmodule
module dut (output logic [7:0] o);
  sub #(.M(8'h5a)) u (.o(o));
endmodule
