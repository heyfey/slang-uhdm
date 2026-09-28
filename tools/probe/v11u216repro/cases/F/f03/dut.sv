// § ndaSizeQueryFold216 — $size of an enum variable in a net initializer
module dut (output logic [7:0] o);
  typedef enum logic [2:0] {A, B, C} e_t;
  e_t e;
  wire [7:0] w = $size(e);
  assign o = w;
endmodule
