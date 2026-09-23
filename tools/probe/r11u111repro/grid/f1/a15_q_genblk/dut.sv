package q;
  typedef logic [2:0] mask_t;
endpackage
module sub #(parameter q::mask_t M = '0) (output logic [2:0] o);
  assign o = M;
endmodule
module dut (output logic [5:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    sub #(.M(3'(i))) u (.o(o[i*3+:3]));
  end
endmodule
