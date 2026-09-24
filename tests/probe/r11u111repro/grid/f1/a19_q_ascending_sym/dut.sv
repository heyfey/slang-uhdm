package q;
  parameter int NF = 4;
  typedef logic [0:NF-1] mask_t;
endpackage
module sub #(parameter q::mask_t M = '0) (output logic [3:0] o);
  assign o = M;
endmodule
module dut (output logic [3:0] o);
  sub #(.M(4'b1001)) u (.o(o));
endmodule
