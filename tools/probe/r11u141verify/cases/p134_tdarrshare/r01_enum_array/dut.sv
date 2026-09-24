// § defNetTypedefArrayShares134
// case r01: an unpacked array of a module enum typedef
module top(output logic [1:0] o);
  typedef enum logic [1:0] { A, B, C } e_t;
  e_t f [2];
  assign f[0] = B;
  assign o = f[0];
endmodule
