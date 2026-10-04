// § vlogEnumByteBaseUnsigned235
module top(output [7:0] o);
  typedef enum byte unsigned {A=1, B=2} eb_t;
  typedef enum byte signed {C=-1, D=2} ec_t;
  eb_t x; ec_t y;
  assign o = x ^ y;
endmodule
