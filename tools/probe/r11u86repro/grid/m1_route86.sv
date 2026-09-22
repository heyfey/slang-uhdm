// r11u86 arm m1 — THE ROUTE AXES SEPARATED: hop home (package vs module-own)
// x typespec home (package vs module) x spelling.  All members 24 bits so a
// member-width resize is visible as 24.
package m1p;
  localparam PU = 5;
  localparam PD = 16'd5;
  localparam PH = 16'h5;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
  } tp;
endpackage
module m1_route86;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
  } tm;
  localparam MU = 5;
  localparam MD = 16'd5;
  localparam MH = 16'h5;
  // pkg hops, pkg typespec
  localparam m1p::tp A_PP = '{bail: 8'hxA, a: m1p::PU, b: m1p::PH, c: m1p::PD};
  // pkg hops, module typespec
  localparam tm      A_PM = '{bail: 8'hxA, a: m1p::PU, b: m1p::PH, c: m1p::PD};
  // module hops, pkg typespec
  localparam m1p::tp A_MP = '{bail: 8'hxA, a: MU, b: MH, c: MD};
  // module hops, module typespec
  localparam tm      A_MM = '{bail: 8'hxA, a: MU, b: MH, c: MD};
endmodule
