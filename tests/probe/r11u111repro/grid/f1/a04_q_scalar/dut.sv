package q;
  typedef logic s_t;
endpackage
module sub #(parameter q::s_t M = 1'b0) (output logic o);
  assign o = M;
endmodule
module dut (output logic o);
  sub #(.M(1'b1)) u (.o(o));
endmodule
