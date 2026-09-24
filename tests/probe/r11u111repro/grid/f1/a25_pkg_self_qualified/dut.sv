package q;
  localparam int NF = 3;
  typedef logic [NF-1:0] mask_t;
  parameter q::mask_t QM = 3'b110;
endpackage
module dut (output logic [2:0] o);
  assign o = q::QM;
endmodule
