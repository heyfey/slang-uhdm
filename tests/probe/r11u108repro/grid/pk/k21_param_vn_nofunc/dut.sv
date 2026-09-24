package q;
  localparam int unsigned NF = 3;
  typedef logic [0:NF-1] mask_t;
endpackage
module sub #(parameter q::mask_t M = '0) (output logic [2:0] o);
  assign o = M;
endmodule
module dut (output logic [2:0] o);
  sub #(.M(3'b101)) u (.o(o));
endmodule
