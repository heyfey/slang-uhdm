// § enumCastChainKeepsInnerCast493
package p;
  typedef enum bit [1:0] {I0, I1, I2} sev_e;
  typedef struct packed { bit [1:0] a; } st_e;
  typedef logic [1:0] two_t;
  typedef enum bit [1:0] {A0, A1} oth_e;
  function void report(sev_e severity);
  endfunction
  function void m(int severity);
    report(sev_e'(st_e'(severity)));
  endfunction
endpackage
module top;
  import p::*;
  sev_e x;
endmodule
