// § pkgPatMemberReadAtValue195 — grid P/p12 (r11u195)
package p;
  typedef struct packed { logic [7:0] A; logic [7:0] D; } cfg_t;
  localparam cfg_t B = '{A:8'd2, D:8'd8};
  localparam int W = B.D;
endpackage
module top (input logic [p::W-1:0] i, output logic o);
  assign o = i[0];
endmodule
