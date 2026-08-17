// r10earl55 a2 — WHICH factor picks golden's kind?  a1 refuted the two obvious
// ones on its own (width alone: a TOP module gives int_typespec at EVERY width
// 1..65; declaration order alone: a1's 39 cells are all int).  The remaining
// candidates a1 could not separate, because it varied two things at once:
//   * TOP module vs CHILD instance
//   * one instance of the definition vs several
//   * position of the declaration inside the module
//   * the fold's WIDTH inside a single child instance
// a2 varies exactly one at a time.
package pk2_55;
  parameter int N1  = 1;
  parameter int N15 = 15;
  parameter int N32 = 32;
endpackage

module a2_earl55;
  c2_55  u_c2  (.o());          // ONE instance, four widths inside it
  c3_55  u_c3  (.o());          // ONE instance, the pinmux triple (32,15,15)
  c4_55  u_c4a (.o());          // TWO instances of the same definition,
  c4_55  u_c4b (.o());          // identical parameters
  c5_55 #(.NR(15)) u_c5 (.o()); // ONE instance, width from an OVERRIDDEN param
  c6_55  u_c6  (.o());          // ONE instance, widths in DESCENDING order
endmodule

// four widths, one child instance, ascending declaration order
module c2_55 (output logic o);
  localparam logic [1-1:0]  W1  = {1{1'b1}};
  localparam logic [2-1:0]  W2  = {2{1'b1}};
  localparam logic [15-1:0] W15 = {15{1'b1}};
  localparam logic [32-1:0] W32 = {32{1'b1}};
  assign o = W1[0] ^ W2[0] ^ W15[0] ^ W32[0];
endmodule

// the pinmux triple, verbatim shape: package-parameter widths 32, 15, 15
module c3_55 (output logic o);
  localparam logic [pk2_55::N32-1:0] M32 = {pk2_55::N32{1'b1}};
  localparam logic [pk2_55::N15-1:0] D15 = {pk2_55::N15{1'b1}};
  localparam logic [pk2_55::N15-1:0] E15 = {pk2_55::N15{1'b1}};
  assign o = M32[0] ^ D15[0] ^ E15[0];
endmodule

// same definition, TWO instances, no parameters at all
module c4_55 (output logic o);
  localparam logic [15-1:0] Q15 = {15{1'b1}};
  assign o = Q15[0];
endmodule

// width from the instance's OVERRIDDEN parameter, single instance
module c5_55 #(parameter int NR = 1) (output logic o);
  localparam logic [NR-1:0] R = {NR{1'b1}};
  assign o = R[0];
endmodule

// the same four widths DESCENDING, to separate "first declaration" from "width"
module c6_55 (output logic o);
  localparam logic [32-1:0] X32 = {32{1'b1}};
  localparam logic [15-1:0] X15 = {15{1'b1}};
  localparam logic [2-1:0]  X2  = {2{1'b1}};
  localparam logic [1-1:0]  X1  = {1{1'b1}};
  assign o = X1[0] ^ X2[0] ^ X15[0] ^ X32[0];
endmodule
