// § anonAggElemKeywordTs247
typedef struct packed { bit [3:0] a; byte b; } sp_t;
typedef struct { bit [3:0] pair [2]; int unsigned w [2]; byte unsigned q [2]; } su_t;
module top(input logic [3:0] a, output logic [3:0] o);
  su_t s;
  sp_t k;
  assign s.pair[0] = a;
  assign s.pair[1] = ~a;
  assign s.w[0] = a;
  assign s.w[1] = 0;
  assign s.q[0] = a; assign s.q[1] = 0;
  assign k = {a, 8'h3};
  assign o = s.pair[a[0]] ^ s.w[0][3:0] ^ k.a ^ s.q[0][3:0];
endmodule
