package q;
  typedef logic [2:0] mask_t;
  typedef mask_t m2_t;
endpackage
module sub #(parameter q::m2_t M = '0) (output logic [2:0] o);
  assign o = M;
endmodule
module dut (output logic [2:0] o);
  sub #(.M(3'b101)) u (.o(o));
endmodule
