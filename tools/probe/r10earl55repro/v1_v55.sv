// v55 adversarial arm 1 — WIDTH-1 with consumers a4 did NOT cross.
// The law under test says: at width 1 EVERY consumer gives the loc-less
// int_typespec.  a4 crossed 11 consumers.  These are the ones it missed, and
// several of them are HARD constant reductions (a declaration RANGE, an array
// index, a for-loop bound, a case item, $bits, a re-replication).
// MEASURED (v55census + v55attrib, elab AND plain views, both binaries):
// TO-GOLDEN 12 / AWAY-GOLDEN 0 / STILL-WRONG 0.  Every one of the twelve
// consumers a4 did not cross — including a DECLARATION RANGE, an ARRAY INDEX, a
// FOR-LOOP BOUND, a CASE ITEM, $bits and a RE-REPLICATION — gives golden's
// loc-less int_typespec at width 1.  The one UNMOVED-BAD cell is R1's shape.
module v1_v55(input logic ext);
  n0_v55 u_n0 (.o(), .ext(ext));
  n1_v55 u_n1 (.o(), .ext(ext));
  n2_v55 u_n2 (.o(), .ext(ext));
  n3_v55 u_n3 (.o(), .ext(ext));
  n4_v55 u_n4 (.o(), .ext(ext));
  n5_v55 u_n5 (.o(), .ext(ext));
  n6_v55 u_n6 (.o(), .ext(ext));
  n7_v55 u_n7 (.o(), .ext(ext));
  n8_v55 u_n8 (.o(), .ext(ext));
  n9_v55 u_n9 (.o(), .ext(ext));
  na_v55 u_na (.o(), .ext(ext));
  nb_v55 u_nb (.o(), .ext(ext));
endmodule

// n0: the param sizes ANOTHER DECLARATION's range (a type-context reduction)
module n0_v55 (output logic o, input logic ext);
  localparam logic [0:0] X = {1{1'b1}};
  logic [X:0] sig;
  assign sig = {2{ext}};
  assign o = sig[0];
endmodule

// n1: the param sizes ANOTHER PARAMETER
module n1_v55 (output logic o, input logic ext);
  localparam logic [0:0] X = {1{1'b1}};
  localparam int Y = X;
  assign o = ext ^ Y[0];
endmodule

// n2: the param indexes an ARRAY
module n2_v55 (output logic o, input logic ext);
  localparam logic [0:0] X = {1{1'b1}};
  logic [1:0] arr;
  assign arr = {2{ext}};
  assign o = arr[X];
endmodule

// n3: the param is a FOR-LOOP bound in a generate
module n3_v55 (output logic o, input logic ext);
  localparam logic [0:0] X = {1{1'b1}};
  for (genvar g = 0; g <= X; g++) begin : gl wire wg = ext; end
  assign o = ext;
endmodule

// n4: the param is a CASE ITEM
module n4_v55 (output logic o, input logic ext);
  localparam logic [0:0] X = {1{1'b1}};
  logic r;
  always_comb begin
    case (ext)
      X[0]: r = 1'b1;
      default: r = 1'b0;
    endcase
  end
  assign o = r;
endmodule

// n5: $bits() of the param
module n5_v55 (output logic o, input logic ext);
  localparam logic [0:0] X = {1{1'b1}};
  localparam int B = $bits(X);
  assign o = ext ^ B[0];
endmodule

// n6: the param is RE-REPLICATED into a wider param
module n6_v55 (output logic o, input logic ext);
  localparam logic [0:0] X = {1{1'b1}};
  localparam logic [3:0] Y = {4{X}};
  assign o = ext ^ Y[0];
endmodule

// n7: the param is COMPARED (a constant-folding equality)
module n7_v55 (output logic o, input logic ext);
  localparam logic [0:0] X = {1{1'b1}};
  assign o = (X == 1'b1) ? ext : 1'b0;
endmodule

// n8: the param drives a PORT CONNECTION of a submodule (a HighConn actual)
module n8_v55 (output logic o, input logic ext);
  localparam logic [0:0] X = {1{1'b1}};
  kk_v55 u_k (.a(X), .z(o));
endmodule

// n9: the param is read in an INITIAL block
module n9_v55 (output logic o, input logic ext);
  localparam logic [0:0] X = {1{1'b1}};
  logic r;
  initial r = X[0];
  assign o = r;
endmodule

// na: the param is the CONDITION of a ternary inside a wider concat
module na_v55 (output logic o, input logic ext);
  localparam logic [0:0] X = {1{1'b1}};
  assign o = {X, X} == 2'b11 ? ext : 1'b0;
endmodule

// nb: the param feeds a FUNCTION call argument
module nb_v55 (output logic o, input logic ext);
  localparam logic [0:0] X = {1{1'b1}};
  function automatic logic f(input logic a); return a; endfunction
  assign o = f(X[0]) ^ ext;
endmodule

module kk_v55 (input logic a, output logic z); assign z = a; endmodule
