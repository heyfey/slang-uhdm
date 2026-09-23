package q;
  typedef bit [3:0] b_t;
endpackage
module sub #(parameter q::b_t M = '0) (output logic [3:0] o);
  assign o = M;
endmodule
module dut (output logic [3:0] o);
  sub #(.M(4'h9)) u (.o(o));
endmodule
