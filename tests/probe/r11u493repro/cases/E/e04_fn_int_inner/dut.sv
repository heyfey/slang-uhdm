// § enumCastChainKeepsInnerCast493
module top(input int s);
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  typedef struct packed { bit [1:0] a; } st_e;
  typedef logic [1:0] two_t;
  typedef enum bit [1:0] {A0, A1} oth_e;
  function void f(int s);
    sev_e v;
    v = sev_e'(int'(s));
  endfunction
endmodule
