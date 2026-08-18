// r10earl68 arm a2 — THE LHS-TYPESPEC dimension of the whole-Rhs genvar fold.
// Surelog runs `adjustSize(tps)` on the reduced Rhs, where `tps` is the LHS's
// typespec: a plain `ref_obj` Lhs binds the variable and hands over ITS
// typespec (size + mask), while a SELECT Lhs hands over none and the Value's
// own 64-bit encoding survives.  MEASUREMENT ONLY.
interface if_gv68;
  logic [7:0] a;
  logic [7:0] b;
  for (genvar i = 0; i < 2; i++) begin : g_if
    if (i >= 0) begin : b1
      logic [7:0] w;
      assign w = i;                  // whole-Rhs genvar in an INTERFACE gen scope
    end
  end
endinterface

module ch_gv68 #(parameter int unsigned P = 0) (output logic [7:0] o);
  for (genvar i = 0; i < 2; i++) begin : g_ch
    if (i >= 0) begin : b1
      logic [7:0] cw;
      assign cw = i;                 // same shape in a CHILD instance
    end
  end
  assign o = g_ch[0].b1.cw ^ g_ch[1].b1.cw ^ P[7:0];
endmodule

typedef struct packed { logic [3:0] hi; logic [3:0] lo; } st_gv68;

module a2_lhs68 (input logic [7:0] din, output logic [7:0] dout);
  logic [7:0]  v8;
  logic [3:0]  v4;
  logic        v1;
  logic [99:0] v100;
  wire  [7:0]  n8;
  int          vint;
  integer      vinteger;
  byte         vbyte;
  bit   [5:0]  vbit6;
  logic signed [7:0] vs8;
  st_gv68      vst;
  logic [31:0][7:0] arr;
  logic [63:0] wide;
  logic [7:0]  ca, cb;

  // 12 unrollings so the masking cases have values above every width.
  for (genvar i = 0; i < 12; i++) begin : g_w
    if (i >= 0) begin : b1
      if (i == 3) begin : c8      assign v8      = i; end
      if (i == 4) begin : c4      assign v4      = i; end   // 4-bit
      if (i == 5) begin : c1      assign v1      = i; end   // 1-bit  (mask!)
      if (i == 6) begin : c100    assign v100    = i; end   // 100-bit
      if (i == 7) begin : cn8     assign n8      = i; end   // a NET, not a var
      if (i == 8) begin : cint    assign vint    = i; end   // int (signed 32)
      if (i == 9) begin : cinteg  assign vinteger= i; end   // integer
      if (i == 10) begin : cbyte  assign vbyte   = i; end   // byte
      if (i == 11) begin : cbit6  assign vbit6   = i; end   // bit [5:0]
      if (i == 2) begin : cs8     assign vs8     = i; end   // signed
    end
  end

  // LHS KINDS, all at distance 1, one unrolling each.
  for (genvar i = 1; i < 2; i++) begin : g_k
    if (i >= 0) begin : b1
      assign arr[i]       = i;      // bit_select Lhs
      assign wide[7:0]    = i;      // part_select Lhs
      assign wide[i +: 8] = i;      // indexed_part_select Lhs
      assign {ca, cb}     = i;      // concat Lhs
      assign vst.lo       = i;      // struct member Lhs
    end
  end

  if_gv68 the_if ();
  logic [7:0] chout0, chout1;
  ch_gv68 #(.P(1)) u_ch0 (.o(chout0));
  ch_gv68 #(.P(2)) u_ch1 (.o(chout1));

  assign dout = v8 ^ v4 ^ {7'b0, v1} ^ v100[7:0] ^ n8 ^ vint[7:0] ^
                vinteger[7:0] ^ vbyte ^ {2'b0, vbit6} ^ vs8 ^ {vst.hi, vst.lo} ^
                arr[1] ^ wide[7:0] ^ ca ^ cb ^ chout0 ^ chout1 ^
                the_if.g_if[0].b1.w ^ the_if.g_if[1].b1.w ^ din;
endmodule
