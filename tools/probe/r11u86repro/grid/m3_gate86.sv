// r11u86 arm m3 — THE GATES: a DIRECT literal member beside the same spelling
// one hop up; a cast over a hop; depth-3 chains; an instance override; a
// generate-scope home; an `s`-marked decimal; and the PACKAGE pattern control.
package m3p;
  localparam PD = 16'd5;
  localparam PO = 16'o5;
  localparam PSD = 16'sd5;
  localparam PCH2 = PD;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t3;
  localparam t3 PKGCTL3 = '{bail: 8'hxA, a: 16'd5, b: PD, c: 16'o5, d: PO,
                            e: PSD, f: PCH2, g: unsigned'(PD)};
endpackage
module m3_gate86;
  localparam MD = 16'd5;
  localparam MO = 16'o5;
  localparam MSD = 16'sd5;
  localparam MCH2 = MD;
  localparam MCH3 = MCH2;
  // DIRECT literal vs the same spelling one hop up, in a MODULE pattern
  localparam m3p::t3 DIRECT = '{bail: 8'hxA, a: 16'd5, b: MD, c: 16'o5, d: MO,
                                e: MSD, f: MCH3, g: unsigned'(MD)};
  localparam m3p::t3 PKGHOP = '{bail: 8'hxA, a: 16'd5, b: m3p::PD, c: 16'o5,
                                d: m3p::PO, e: m3p::PSD, f: m3p::PCH2,
                                g: unsigned'(m3p::PD)};
  m3_sink #(.R(DIRECT)) s1();
  m3_sink #(.R(m3p::PKGCTL3)) s2();
  m3_sink #(.R('{bail: 8'hxA, a: 16'd5, b: MD, c: 16'o5, d: MO,
                 e: MSD, f: MCH3, g: unsigned'(MD)})) s3();
endmodule
module m3_sink #(parameter m3p::t3 R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
