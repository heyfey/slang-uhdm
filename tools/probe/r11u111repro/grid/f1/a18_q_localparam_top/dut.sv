package q;
  localparam int NF = 3;
  typedef logic [NF-1:0] mask_t;
endpackage
module dut (output logic [2:0] o);
  localparam q::mask_t L = 3'b101;
  parameter q::mask_t P = 3'b011;
  assign o = L ^ P;
endmodule
