// r10v83 arm 6 — THE SIGNEDNESS AND OPERAND-WIDTH PROBE.  The law's predicate
// is "UNBASED decimal, or based-and-unsigned"; ExprEval's own test is the
// operand constant's SIGNED TYPESPEC.  These are the shapes where the two
// could disagree, plus operands wider than slang's default 32-bit unsized
// decimal.  MEASUREMENT ONLY.
module snk6_83 (input logic [63:0] a, output logic [63:0] y);
  assign y = ~a;
endmodule

module v6_signwidth83;
  logic [63:0] v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,va,vb;

  // Q01 unsized decimal LARGER than 32 bits
  snk6_83 q01 (.a(40'(4294967296)),   .y(v0));
  // Q02 unsized decimal exactly 2**31
  snk6_83 q02 (.a(40'(2147483648)),   .y(v1));
  // Q03 unsized decimal 2**31-1
  snk6_83 q03 (.a(40'(2147483647)),   .y(v2));
  // Q04 unsized BASED decimal 'd5   (no size, has a base)
  snk6_83 q04 (.a(12'('d5)),          .y(v3));
  // Q05 unsized SIGNED based decimal 'sd5
  snk6_83 q05 (.a(12'('sd5)),         .y(v4));
  // Q06 sized unsigned hex with the top bit set
  snk6_83 q06 (.a(32'(32'hFFFFFFFF)), .y(v5));
  // Q07 sized SIGNED hex with the top bit set
  snk6_83 q07 (.a(32'(32'shFFFFFFFF)),.y(v6));
  // Q08 sized signed binary
  snk6_83 q08 (.a(12'(4'sb1)),        .y(v7));
  // Q09 sized unsigned octal
  snk6_83 q09 (.a(12'(6'o17)),        .y(v8));
  // Q10 a 65-bit based literal (wider than uint64)
  snk6_83 q10 (.a(32'(65'h1_0000_0000_0000_0001)), .y(v9));
  // Q11 unbased '1 (all ones)
  snk6_83 q11 (.a(12'('1)),           .y(va));
  // Q12 unbased '0
  snk6_83 q12 (.a(12'('0)),           .y(vb));

  wire [63:0] acc6 = v0^v1^v2^v3^v4^v5^v6^v7^v8^v9^va^vb;
endmodule
