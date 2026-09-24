package q;
  localparam int NF = 3;
  typedef logic [1:0][NF-1:0] mask_t;
endpackage
module sub #(parameter q::mask_t M = '0) (output logic [5:0] o);
  assign o = M;
endmodule
module dut (output logic [5:0] o);
  sub #(.M(6'h2d)) u (.o(o));
endmodule
