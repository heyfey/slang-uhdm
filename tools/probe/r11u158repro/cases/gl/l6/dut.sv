// § genCaLhsEnumConstClone158
module dut(input logic [3:0][7:0] a, output logic [3:0][7:0] o);
  typedef enum logic [1:0] {A, B, C, D} e_t;
  assign o[C:A] = a[C:A];
  assign o[D] = a[D];
endmodule
