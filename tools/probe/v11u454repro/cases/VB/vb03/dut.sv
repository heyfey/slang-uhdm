// § unpackedDimBasedLitKept454
module top;
  typedef struct { int x [8'h3:0]; logic y; } s_t;
  s_t s;
  typedef int arr_t [4'h3:0];
  arr_t t;
  initial begin s.y = 0; t[0] = 1; end
endmodule
