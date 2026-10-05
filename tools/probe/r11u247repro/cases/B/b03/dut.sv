// § anonAggElemKeywordTs247
typedef bit pb_t [3];
typedef bit signed [7:0] ps_t [2];
module top(input logic a, output logic o);
  pb_t t;
  ps_t s;
  assign t[0] = a;
  assign t[1] = a;
  assign t[2] = a;
  assign s[0] = {8{a}};
  assign s[1] = 8'h0;
  assign o = t[0] ^ t[2] ^ s[0][3];
endmodule
