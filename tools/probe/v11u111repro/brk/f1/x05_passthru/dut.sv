package q;
  localparam int NF = 4;
  typedef logic [NF-1:0] mask_t;
endpackage
module leaf #(parameter q::mask_t M = '0) (output logic [3:0] o);
  assign o = M + 1;
endmodule
module mid #(parameter q::mask_t M = 4'h1) (output logic [3:0] o);
  leaf #(.M(M)) l (.o(o));
endmodule
module dut (output logic [3:0] o, output logic [3:0] p);
  mid #(.M(4'h9)) m (.o(o));
  mid m2 (.o(p));
endmodule
