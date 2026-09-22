// r11v94 BREAK arm x4 — LAW A where the initializer is NOT a literal leaf and
// NOT a name: an OPERATION, a CONCATENATION, a constant FUNCTION CALL, a
// STRING-free cast and a negative, each under an implicit SIGNED and an
// implicit UNSIGNED declaration, read by an UNSIGNED and by a SIGNED reader.
// These are the shapes where the width face DECLINES but the sign face and
// the has-a-typespec VOTE still fire, so a wrong decode shows as a
// half-golden cell.
package x4p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  function automatic int fq(input int a); return a + 1; endfunction
  localparam signed        KSO = 3 + 4;
  localparam unsigned      KUO = 3 + 4;
  localparam signed        KSN = -3;
  localparam unsigned      KUN = -3;
  localparam signed [7:0]  KSDN = -3;
  localparam signed        KSF = fq(4);
  localparam signed        KSK = {4'd1, 4'd2};
  localparam signed        KSX = 8'(5);
endpackage
module x4_syncross94v;
  localparam logic [7:0]         M1 = x4p::KSO;
  localparam logic signed [31:0] M2 = x4p::KUO;
  localparam logic [7:0]         M3 = x4p::KSN;
  localparam logic [7:0]         M4 = x4p::KUN;
  localparam logic [7:0]         M5 = x4p::KSDN;
  localparam logic [7:0]         M6 = x4p::KSF;
  localparam logic [7:0]         M7 = x4p::KSK;
  localparam logic [7:0]         M8 = x4p::KSX;
  localparam logic signed [31:0] M9 = x4p::KSO;
  localparam x4p::t A = '{bail: 8'hxA, a: M1, b: M2, c: M3, d: M4,
                          e: M5, f: M6, g: M7};
  localparam x4p::t B = '{bail: 8'hxA, a: M8, b: M9, c: M1, d: M2,
                          e: M3, f: M4, g: M5};
  x4_sink #(.R(A)) s1();
  x4_sink #(.R(B)) s2();
endmodule
module x4_sink #(parameter x4p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
