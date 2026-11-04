package pkg;
  typedef enum logic [7:0] {bb=8'hBB, cc=8'hCC} e8_t;
endpackage
module top(output logic [7:0] o);
  pkg::e8_t b = pkg::bb;
  assign o = b;
endmodule
