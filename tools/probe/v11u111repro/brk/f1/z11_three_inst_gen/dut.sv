package q;
  localparam int NF = 3;
  typedef logic [NF-1:0] mask_t;
endpackage
module sub #(parameter q::mask_t M = '0) (output logic [2:0] o);
  assign o = M;
endmodule
module dut (output logic [8:0] o);
  for (genvar g = 0; g < 3; g++) begin : gl
    sub #(.M(3'(g))) u (.o(o[g*3 +: 3]));
  end
endmodule
