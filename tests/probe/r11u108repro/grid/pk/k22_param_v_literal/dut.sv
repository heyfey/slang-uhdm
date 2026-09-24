package q;
  typedef logic [0:2] mask_t;
endpackage
module sub #(parameter q::mask_t M = '0) (output logic [2:0] o);
  assign o = M;
endmodule
module dut (output logic [2:0] o);
  sub #(.M(3'b101)) u (.o(o));
endmodule
