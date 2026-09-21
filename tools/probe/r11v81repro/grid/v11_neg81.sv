// r11v81 adversarial arm v11 — negative and `s`-marked based stores one hop
// up, the faces RV-4 names.
package v11p;
  localparam ND = -16'd5;
  localparam SB = 16'sb101;
  localparam SH = 16'sh5;
  localparam SO = 16'so5;
  localparam UB2 = 16'b101;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e;
  } t11;
  localparam t11 J = '{bail: 8'hxA, a: ND, b: SB, c: SH, d: SO, e: UB2};
endpackage
module v11_neg81 #(parameter v11p::t11 CJ = v11p::J) (output logic [23:0] o);
  assign o = CJ.a ^ CJ.b ^ CJ.c ^ CJ.d ^ CJ.e;
endmodule
