// r10v91 arm 3 — HOMES x INSTANCES x hier_path FACES for the r10earl91 law.
package p3;
  typedef struct packed { logic [7:0] a; logic [3:0] b; } sm_t;
  typedef struct packed { sm_t inner; logic [3:0] c; } nst_t;
  typedef logic [11:0] wa_t [2];
endpackage

interface ifc3;
  logic [11:0] sig;
  p3::sm_t     st;
  modport mp (input sig, input st);
endinterface

module leaf3 #(parameter int W = 12) (input logic [W-1:0] d, output logic [W-1:0] o, ifc3 itf);
  logic [W-1:0] a1 [2];
  p3::nst_t nn;
  p3::sm_t  sarr [2];
  assign nn = p3::nst_t'(d);
  assign sarr = '{p3::sm_t'(d), p3::sm_t'(d)};
  // hier_path faces as operand 0 of an inline-unpacked-array pattern
  assign a1 = '{nn.inner.a, d};            // NESTED packed-struct member read
  logic [W-1:0] a2 [2];
  assign a2 = '{sarr[1].a, d};             // unpacked-array-of-struct ELEMENT member
  logic [W-1:0] a3 [2];
  assign a3 = '{itf.sig, d};               // INTERFACE signal
  logic [W-1:0] a4 [2];
  assign a4 = '{itf.st.a, d};              // interface STRUCT member
  logic [W-1:0] a5 [2];
  assign a5 = '{nn.inner.a + 1'b1, d};     // hier_path inside an OPERATION
  logic [W-1:0] a6 [2];
  assign a6 = '{{nn.inner.a, 4'd0}, d};    // hier_path in a CONCAT
  logic [W-1:0] a7 [2];
  assign a7 = '{W'(nn.inner.a), d};        // hier_path under a CAST
  assign o = a1[0]^a2[0]^a3[0]^a4[0]^a5[0]^a6[0]^a7[0];
endmodule

module mid3 (input logic [11:0] d, output logic [11:0] o, ifc3 itf);
  logic [11:0] x [3];
  leaf3 #(.W(12)) l0 (.d(d), .o(x[0]), .itf(itf));
  leaf3 #(.W(12)) l1 (.d(d), .o(x[1]), .itf(itf));
  leaf3 #(.W(1))  l2 (.d(d[0]), .o(), .itf(itf));
  assign x[2] = 12'd0;
  assign o = x[0]^x[1];
endmodule

module v3_homes91 #(parameter int NG = 3) (input logic [11:0] din, output logic [11:0] q, ifc3 itf);
  logic [11:0] r [NG];
  genvar gi;
  generate
    for (gi = 0; gi < NG; gi++) begin : gblk
      logic [11:0] gv [2];
      assign gv = '{din, din};                 // gen-for home
      mid3 m (.d(din ^ gv[0]), .o(r[gi]), .itf(itf));
    end
    if (NG > 1) begin : gif
      logic [11:0] iv [2];
      assign iv = '{din, 12'd3};               // gen-if home
      p3::wa_t tv;
      assign tv = '{din, 12'd3};               // typedef'd, gen-if home (KEEP)
    end
  endgenerate
  // a 3-deep chain reference as operand 0
  logic [11:0] deep [2];
  assign deep = '{gblk[0].gv[1], din};
  assign q = r[0]^r[1]^r[2]^deep[0]^gif.iv[0]^gif.tv[0];
endmodule

module top_v3 (input logic [11:0] din, output logic [11:0] q);
  ifc3 itf();
  assign itf.sig = din;
  assign itf.st  = p3::sm_t'(din);
  v3_homes91 #(.NG(3)) u (.din(din), .q(q), .itf(itf));
endmodule
