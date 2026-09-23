package q;
  typedef logic signed [1:0][2:0] mask_t;
endpackage
module sub #(parameter q::mask_t M = '0) (output logic [5:0] o);
  assign o = M;
endmodule
module dut (output logic [5:0] o);
  sub #(.M(6'sh15)) u (.o(o));
endmodule
