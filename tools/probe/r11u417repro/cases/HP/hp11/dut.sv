// § hierSelParenBoundPretty417
module top #(parameter int A = 27, parameter int B = 3) (output logic [8:0] o);
  typedef struct packed { logic [26:0] vpn; } t_s;
  t_s s;
  assign o = s.vpn[(A/B)-1:0];
endmodule
