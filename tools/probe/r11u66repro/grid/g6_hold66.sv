// r11u66 arm g6 — WHICH MINT THIS PASS CLAIMS, AND THE HOLDERS AROUND IT
// (caution (e)).  One INT-answering setter (K - 1) and one UINT-answering
// setter (KU << 1) carried through every holder the flat op75 walk serves:
// the package DEF and ELAB listings, a module localparam, an imported copy,
// a parameter PORT, an OVERRIDDEN parameter port, an interface localparam,
// a generate-block localparam, the POSITIONAL pattern form and a pure
// `default:` fill — plus the UNPACKED twin of each.
package q6;
  localparam int K = 6;
  localparam int unsigned KU = 6;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } p6_t;
  typedef struct { int a; int b; } u6_t;
  localparam p6_t PK = '{a: K - 1, b: KU << 1};   // package, packed
  localparam u6_t UK = '{a: K - 1, b: KU << 1};   // package, unpacked
endpackage

interface if6 #(parameter q6::p6_t IP = '{a: 6 - 1, b: 2});
  localparam int K6 = 6;
  localparam q6::p6_t IL = '{a: K6 - 1, b: 2};
  logic [31:0] w;
  assign w = IL.a;
endinterface

module g6child #(parameter q6::p6_t PP = '{a: 1, b: 2}) (output logic [31:0] y);
  assign y = PP.a;
endmodule

module g6_hold66
  import q6::*;
  #(parameter q6::p6_t PORT = '{a: K - 1, b: KU << 1})
  (output logic [31:0] y0, output logic [31:0] y1, output logic [31:0] y2,
   output logic [31:0] y3, output logic [31:0] y4, output logic [31:0] y5,
   output logic [31:0] y6, output logic [31:0] y7, output logic [31:0] y8);
  localparam int LK = 6;
  localparam int unsigned LKU = 6;
  // a MODULE-LOCAL packed struct localparam
  typedef struct packed { logic [31:0] a; logic [31:0] b; } m6_t;
  localparam m6_t ML = '{a: LK - 1, b: LKU << 1};
  // a MODULE-LOCAL UNPACKED struct localparam (the r11u61 road)
  typedef struct { int a; int b; } n6_t;
  localparam n6_t NL = '{a: LK - 1, b: LKU << 1};
  // the POSITIONAL form
  localparam m6_t MP = '{LK - 1, LKU << 1};
  // a pure `default:` fill
  localparam m6_t MD = '{default: LK - 1};
  assign y0 = q6::PK.a;      // the imported package parameter, packed
  assign y1 = q6::UK.a;      // the imported package parameter, unpacked
  assign y2 = PORT.a;        // the parameter PORT's own default
  assign y3 = ML.a;
  assign y4 = NL.a;
  assign y5 = MP.a;
  assign y6 = MD.a;
  g6child c1 (.y(y7));                                   // the DEFAULT
  g6child #(.PP('{a: LK - 1, b: LKU << 1})) c2 (.y(y8)); // an OVERRIDE
  if6 u_if ();
  generate
    if (1) begin : gblk
      localparam m6_t GL = '{a: LK - 1, b: LKU << 1};
      logic [31:0] gw;
      assign gw = GL.a;
    end
  endgenerate
endmodule
