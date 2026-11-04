// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output logic [3:0] o);
  typedef enum int {LO = 2, HI = 5} e_t;
  assign o = a[HI:LO];
endmodule
