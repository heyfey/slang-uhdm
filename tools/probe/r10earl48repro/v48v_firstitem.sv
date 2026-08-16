// r10earl48 VERIFIER arm 2 — the FIRST-ITEM test at its edges.
//   x1  a TYPEDEF before the if-generate (slang has a TypeAlias member; is it
//       an ITEM for Surelog's elaborator?)
//   x2  an EMPTY item `;` before the if-generate
//   x3  a PARAMETER after the if-generate (is it dropped like v5's wire?)
//   x4  a promoted block whose only member is another if-generate (recursion
//       meets the EMPTY fence: the promoted block is non-empty only because it
//       holds a generate)
//   x5  the same shape inside a FOR-generate inside an INTERFACE
//   x6  an else arm whose first item is an if-generate with NO else and a
//       FALSE condition, followed by a taken if-generate (a2 u5's shape, R1)
//       -- carried here only to confirm the fence's row on my own binaries.

module x1 ();
  wire a1;
  if (0) begin : x1_t
    wire t;
  end else begin : x1_e
    typedef logic [1:0] x1_ty;
    if (1) begin : x1_c
      wire c;
      assign c = 1'b0;
    end
  end
endmodule

module x2 ();
  wire a2;
  if (0) begin : x2_t
    wire t;
  end else begin : x2_e
    ;
    if (1) begin : x2_c
      wire c;
      assign c = 1'b0;
    end
  end
endmodule

module x3 ();
  wire a3;
  if (0) begin : x3_t
    wire t;
  end else begin : x3_e
    if (1) begin : x3_c
      wire c;
      assign c = 1'b0;
    end
    localparam int X3P = 7;
  end
endmodule

module x4 ();
  wire a4;
  if (0) begin : x4_t
    wire t;
  end else begin : x4_e
    if (1) begin : x4_c
      if (1) begin : x4_d
        wire d;
        assign d = 1'b1;
      end
    end
  end
endmodule

interface x5_if ();
  for (genvar i = 0; i < 2; i++) begin : x5_l
    if (0) begin : x5_t
      wire t;
    end else begin : x5_e
      if (1) begin : x5_c
        wire c;
        assign c = 1'b0;
      end
      if (1) begin : x5_c2
        wire c2;
        assign c2 = 1'b1;
      end
    end
  end
endinterface

module x5 ();
  x5_if u_x5 ();
endmodule
