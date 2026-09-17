// v11u56 ADVERSARIAL arm x4 — THE NESTED CHAIN AND spsPureDef56.  `pdef56` is
// assigned INSIDE the chain loop and the LAST iteration wins, so a nested read
// whose OUTER level is a pure `default:` fill but whose INNER level is a named
// pattern (and the reverse) is where the two-producer split can be mis-keyed.
// Also: a pure default fill at the INNER level, reached through a named outer.
package p;
  typedef struct packed {
    logic [7:0]  a;
    logic [31:0] b;
  } inner_t;
  typedef struct packed {
    inner_t      i;
    logic [15:0] t;
  } outer_t;
  // n1: OUTER named, INNER pure default fill
  localparam outer_t N1 = '{i: '{default: '1}, t: 16'd7};
  // n2: OUTER pure default fill (fills the whole nested struct), no named member
  localparam outer_t N2 = '{default: '1};
  // n3: OUTER named, INNER named with -1 and an enum
  typedef enum logic [3:0] { E_A = 4'd2, E_B = 4'd9 } e_t;
  typedef struct packed {
    logic signed [31:0] s;
    e_t                 e;
  } in2_t;
  typedef struct packed {
    in2_t        q;
    logic [7:0]  u;
  } out2_t;
  localparam out2_t N3 = '{q: '{s: -1, e: E_B}, u: '1};
  // n4: OUTER pure default reaching THROUGH a nested struct (no enum member:
  // a pure fill has no implicit conversion to an enum type).
  typedef struct packed {
    logic signed [31:0] s;
    logic [3:0]         e;
  } in3_t;
  typedef struct packed {
    in3_t        q;
    logic [7:0]  u;
  } out3_t;
  localparam out3_t N4 = '{default: -1};
endpackage
module dut #(parameter p::outer_t A = p::N1, parameter p::outer_t B = p::N2,
             parameter p::out2_t  C = p::N3, parameter p::out3_t  D = p::N4)
           (output logic [31:0] a1, output logic [31:0] a2, output logic [31:0] a3,
            output logic [31:0] b1, output logic [31:0] b2, output logic [31:0] b3,
            output logic signed [31:0] c1, output logic [31:0] c2, output logic [31:0] c3,
            output logic signed [31:0] d1, output logic [31:0] d2, output logic [31:0] d3);
  assign a1 = A.i.a;  assign a2 = A.i.b;  assign a3 = A.t;
  assign b1 = B.i.a;  assign b2 = B.i.b;  assign b3 = B.t;
  assign c1 = C.q.s;  assign c2 = C.q.e;  assign c3 = C.u;
  assign d1 = D.q.s;  assign d2 = D.q.e;  assign d3 = D.u;
endmodule
