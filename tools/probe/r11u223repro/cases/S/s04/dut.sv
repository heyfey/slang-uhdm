// § ndaAdjSizeFoldSized223 — $size(ea, 2) of an enum array: the generic handler (element size times the last range), sized to a 4-bit net
module dut (output logic [7:0] o1);
  typedef enum logic [2:0] {E0, E1, E2} e_t;
  e_t ea [3];
  wire [3:0] w1 = $size(ea, 2);
  assign o1 = w1;
endmodule
