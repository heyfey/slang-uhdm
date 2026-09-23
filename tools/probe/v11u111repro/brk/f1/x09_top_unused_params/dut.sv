package q;
  localparam int NF = 3;
  typedef logic [NF:0] mask_t;
endpackage
module dut #(parameter q::mask_t A = 4'h3, localparam q::mask_t B = A + 1) (output logic [3:0] o);
  localparam q::mask_t C = B;
  assign o = C;
endmodule
