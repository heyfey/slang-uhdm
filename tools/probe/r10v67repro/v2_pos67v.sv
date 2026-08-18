// r10v67 verifier arm 2 — READ POSITION x CARRIER, one hop down, in an ELAB
// gen-scope cont_assign.  Targets the positions the pass's own arms do NOT
// carry: a NESTED index (`w[m[Ku]]`), an index on an ARRAY ELEMENT
// (`mem[Ku][Ku]`), an index on a HIER-PATH base (`u_s.sig[Ku]`), a STREAMING
// operator, an ASSIGNMENT PATTERN, a replication COUNT, a part-select of a
// bit-select's base, a bit-select inside an INDEXED part-select's base, the
// LHS in every one of those, a NET-DECL-ASSIGN (which is emitted OUTSIDE the
// cont_assign loop the new guard wraps) and a bit-select index inside the
// gen scope's own PARAM_ASSIGN Rhs.
module v2sub67 (input logic [15:0] a, output logic [15:0] s);
  assign s = a;
endmodule

module v2_pos67 (input logic [15:0] d, output logic [31:0] y);
  logic [15:0] w, m;
  logic [15:0] mem [0:15];
  assign w = d;
  assign m = ~d;

  for (genvar g = 0; g < 2; g++) begin : pA
    localparam int unsigned Ku = g + 1;
    localparam int unsigned Kv = g + 2;
    for (genvar h = 0; h < 1; h++) begin : pB
      v2sub67 u_s (.a(w), .s());
      logic [15:0] nda = w[Ku];              // NET-DECL-ASSIGN (outside the loop)
      logic [15:0] out1, out2, out3, out4, out5, out6, out7, out8;
      logic [15:0] lhs1, lhs2;
      localparam int unsigned Kpa = Ku + 4;  // param_assign Rhs (no select)
      // nested index: the INNER index is one hop, the OUTER is an expression
      assign out1 = {15'b0, w[m[Ku]]};
      // index on an unpacked-array element select
      assign out2 = {15'b0, mem[Ku][Kv]};
      // index on a hier-path base
      assign out3 = {15'b0, u_s.s[Ku]};
      // streaming operator
      assign out4 = {<< {w[Ku], 15'b0}};   // STREAMING as the whole Rhs
      // replication COUNT is the localparam itself; the payload has an index
      assign out5 = {14'b0, {2{w[Ku]}}};
      // bit-select feeding an indexed part-select base
      assign out6 = {14'b0, w[w[Ku] +: 2]};
      // part-select bounds (the LANDED call sites) beside the index
      assign out7 = {14'b0, w[Kv:Ku]};
      // ternary + operation operand together
      assign out8 = {15'b0, (Ku > 0) ? w[Ku] : w[Kv]};
      // LHS bit-select index
      assign lhs1[Ku] = w[0];
      assign lhs2[Kv:Ku] = 2'b01;
      assign y[g] = |out1 ^ |out2 ^ |out3 ^ |out4 ^ |out5 ^ |out6 ^ |out7 ^
                    |out8 ^ |lhs1 ^ |lhs2 ^ |nda ^ Kpa[0];
    end
  end
  assign y[31:2] = '0;
endmodule
