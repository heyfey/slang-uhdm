package q;
  typedef reg [3:0] mask_t;
endpackage
module sub #(parameter q::mask_t M = 4'h0) (output logic [3:0] o);
  assign o = M;
endmodule
module dut (output logic [3:0] o);
  sub #(.M(4'h3)) u (.o(o));
endmodule
