// § enumCastChainKeepsInnerCast493
module top;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  typedef struct packed { bit [1:0] a; } st_e;
  typedef logic [1:0] two_t;
  typedef enum bit [1:0] {A0, A1} oth_e;
  int x;
  sev_e v;
  initial v = sev_e'(st_e'(x));
endmodule
