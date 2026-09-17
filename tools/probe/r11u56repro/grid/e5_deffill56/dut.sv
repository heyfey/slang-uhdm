// r11u56 arm e5 — WHICH MEMBER SIZES A `default:` FILL.  A named setter is
// resized per member (arms e1/e2/e4); `vv3_default` shows ONE `default: '1`
// answering the SAME value at three member widths, so the fill's value is
// stamped ONCE.  These three structs separate "the LAST default-filled member"
// from "the WIDEST default-filled member" and add a named/default mix.
package p;
  // s1: last (w8) is NARROWER than the widest (w32)
  typedef struct packed {
    logic [31:0] a;
    logic [7:0]  b;
  } s1_t;
  localparam s1_t L1 = '{default: '1};
  // s2: widest (w64) sits in the MIDDLE
  typedef struct packed {
    logic [7:0]  a;
    logic [63:0] b;
    logic [15:0] c;
  } s2_t;
  localparam s2_t L2 = '{default: '1};
  // s3: a NAMED setter on the last member, `default:` on the rest
  typedef struct packed {
    logic [31:0] a;
    logic [7:0]  b;
    logic [15:0] c;
  } s3_t;
  localparam s3_t L3 = '{c: 16'hBEEF, default: '1};
  // s4: `default: '0`
  typedef struct packed {
    logic [31:0] a;
    logic [7:0]  b;
  } s4_t;
  localparam s4_t L4 = '{default: '0};
  // s5: `default: -1`
  typedef struct packed {
    int          a;
    logic [7:0]  b;
  } s5_t;
  localparam s5_t L5 = '{default: -1};
  // s6: `default: 'x` (pure fill, unknown)
  typedef struct packed {
    logic [31:0] a;
    logic [7:0]  b;
  } s6_t;
  localparam s6_t L6 = '{default: 'x};
  // s7: a 96-bit member under a pure `default: '1`
  typedef struct packed {
    logic [95:0] a;
    logic [7:0]  b;
  } s7_t;
  localparam s7_t L7 = '{default: '1};
endpackage
module dut #(parameter p::s1_t P1 = p::L1, parameter p::s2_t P2 = p::L2,
             parameter p::s3_t P3 = p::L3, parameter p::s4_t P4 = p::L4,
             parameter p::s5_t P5 = p::L5,
             parameter p::s6_t P6 = p::L6, parameter p::s7_t P7 = p::L7)
           (output logic [31:0] o1a, output logic [31:0] o1b,
            output logic [31:0] o2a, output logic [63:0] o2b, output logic [31:0] o2c,
            output logic [31:0] o3a, output logic [31:0] o3b, output logic [31:0] o3c,
            output logic [31:0] o4a, output logic [31:0] o4b,
            output logic signed [31:0] o5a, output logic [31:0] o5b,
            output logic [31:0] o6a, output logic [31:0] o6b,
            output logic [95:0] o7a, output logic [31:0] o7b);
  assign o1a = P1.a;  assign o1b = P1.b;
  assign o2a = P2.a;  assign o2b = P2.b;  assign o2c = P2.c;
  assign o3a = P3.a;  assign o3b = P3.b;  assign o3c = P3.c;
  assign o4a = P4.a;  assign o4b = P4.b;
  assign o5a = P5.a;  assign o5b = P5.b;
  assign o6a = P6.a;  assign o6b = P6.b;
  assign o7a = P7.a;  assign o7b = P7.b;
endmodule
