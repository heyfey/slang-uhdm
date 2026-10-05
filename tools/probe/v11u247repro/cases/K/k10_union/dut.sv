// § anonAggElemKeywordTs247
typedef union { bit [3:0] a [2]; int unsigned w; } un_t;
typedef struct { bit b [2]; bit signed [3:0] s [2]; } bs_t;
module top(input logic [3:0] a, output logic [3:0] o);
  un_t u;
  bs_t s;
  assign u.a[0] = a;
  assign s.b[0] = a[0]; assign s.b[1] = a[1];
  assign s.s[0] = a; assign s.s[1] = ~a;
  assign o = u.a[0] ^ {s.b[0], s.b[1], 2'b0} ^ s.s[1];
endmodule
