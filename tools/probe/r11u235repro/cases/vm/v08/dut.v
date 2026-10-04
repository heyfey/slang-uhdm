// § vlogEnumByteBaseUnsigned235
module top(output [7:0] o);
  typedef enum byte {A, B} e_t;
  e_t x;
  assign o = x;
endmodule
