package q;
  localparam int NF = 3;
  typedef logic [NF-1:0] mask_t;
endpackage
module sub #(parameter int W = 3) (input q::mask_t i, output logic [2:0] o);
  assign o = i;
endmodule
module dut (input logic [2:0] i, output logic [2:0] o);
  sub u (.i(i), .o(o));
endmodule
