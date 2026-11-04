package q;
  localparam int NF = 5;
  typedef logic [NF-1:0] mask_t;
endpackage
module sub #(parameter q::mask_t M = 5'h3) (output logic [$bits(M)-1:0] o, output logic [4:0] c);
  logic [4:0] r;
  assign r = M;
  assign o = M ^ 5'h1;
  assign c = r;
endmodule
module dut (output logic [4:0] o, output logic [4:0] c);
  sub u (.o(o), .c(c));
endmodule
