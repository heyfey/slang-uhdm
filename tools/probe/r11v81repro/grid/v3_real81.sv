// r11v81 adversarial arm v3 — a REAL store and a STRING store in their own
// arm (either spelling may refuse to compile; kept apart so it cannot take
// the rest of the grid with it).
package v3p;
  localparam RR = 1.5;
  localparam SS = "abc";
  typedef struct packed {
    logic [23:0] bail; logic [31:0] r; logic [23:0] s;
  } t3;
  localparam t3 C = '{bail: 8'hxA, r: RR, s: SS};
endpackage
module v3_real81 #(parameter v3p::t3 CC = v3p::C) (output logic [23:0] o);
  assign o = CC.s ^ CC.r[23:0];
endmodule
