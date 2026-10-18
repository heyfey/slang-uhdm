// § unpackedUnionTdVar402
module top;
  typedef union { int i; bit [7:0] b; } u_t;
  u_t u;
  initial begin
    u.i = 5;
    u.b = 8'h1;
  end
endmodule
