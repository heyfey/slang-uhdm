// § impEnumParamRefNoSize409
module top;
  typedef enum { A, B, C, D } e_t;
  parameter e_t P = D;
endmodule
