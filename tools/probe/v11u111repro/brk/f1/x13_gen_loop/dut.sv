package q;
  localparam int NF = 2;
  typedef logic [NF:0] mask_t;
endpackage
module sub #(parameter q::mask_t M = '0) (output logic [2:0] o);
  assign o = M;
endmodule
module dut (output logic [5:0] o);
  for (genvar g = 0; g < 2; g++) begin : gl
    localparam q::mask_t GM = g + 1;
    sub #(.M(GM)) u (.o(o[g*3 +: 3]));
  end
endmodule
