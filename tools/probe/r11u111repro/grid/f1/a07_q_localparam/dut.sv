package q;
  localparam int NF = 3;
  typedef logic [NF-1:0] mask_t;
endpackage
module sub #(parameter int W = 3) (output logic [2:0] o);
  localparam q::mask_t L = 3'b101;
  assign o = L;
endmodule
module dut (output logic [2:0] o);
  sub #(.W(4)) u (.o(o));
endmodule
