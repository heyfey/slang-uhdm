// § enumCastChainKeepsInnerCast493
module top(input int s);
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  typedef struct packed { bit [1:0] a; } st_e;
  sev_e y;
  assign y = sev_e'(st_e'(s));
endmodule
