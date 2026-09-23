package q;
  typedef logic [1:0][3:0] md_t;
endpackage
module sub #(parameter q::md_t M = '0) (output logic [7:0] o);
  assign o = M;
endmodule
module dut (output logic [7:0] o);
  sub #(.M(8'h5a)) u (.o(o));
endmodule
