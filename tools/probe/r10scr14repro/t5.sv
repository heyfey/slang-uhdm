// § elabOvRefCopiesParam — does a BARE-REFERENCE override actual take the
// SOURCE parameter's constant SIZE, or the FORMAL's own width?
// The two candidate discriminators are crossed:
//   source: an untyped localparam folding from an OPERATION (INT, size 64)
//           vs an `int` one (INT, size 32)
//   formal: a default that is a plain LITERAL (Surelog derives an
//           int_typespec, so adjustSize can re-render) vs one that is itself
//           an OPERATION (no typespec, nothing to re-render at) vs `int`.
module sub_lit #(parameter P = 8) (output logic o);
    assign o = P[0];
endmodule
module sub_op #(parameter P = 4 * 2) (output logic o);
    assign o = P[0];
endmodule
module sub_int #(parameter int P = 8) (output logic o);
    assign o = P[0];
endmodule

module top (output logic a, b, c, d, e, f);
    localparam     A64 = 1024 * 1024;
    localparam int A32 = 1024 * 1024;
    sub_lit #(.P(A64)) u1 (a);
    sub_lit #(.P(A32)) u2 (b);
    sub_op  #(.P(A64)) u3 (c);
    sub_op  #(.P(A32)) u4 (d);
    sub_int #(.P(A64)) u5 (e);
    sub_int #(.P(A32)) u6 (f);
endmodule
