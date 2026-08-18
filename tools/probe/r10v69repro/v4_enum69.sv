// r10v69 arm v4 - bound KINDS the fold must classify: enum constants, typedef'd
// param, parameter of a parametrised instance, `localparam` of a package,
// escaped identifiers, $-bearing names, and the empty/degenerate groups.
package pv4;
  parameter int UA = 5;
  localparam int UL = 6;
  typedef enum logic [3:0] { EA = 4'd2, EB = 4'd3 } e4_t;
endpackage

typedef struct packed { logic [31:0] f; } rec4_t;

module child4 #(parameter int CP = 5) ();
  logic [31:0] cw;
endmodule

module v4 import pv4::*; ();
  parameter int VP = 5;
  localparam int VL = 6;
  rec4_t arr [4];
  logic [7:0] o [64];
  logic       ob [64];
  logic [31:0] \esc[3] ;

  for (genvar i = 0; i < 2; i++) begin : g4
    // ENUM CONSTANT as an ips bound
    assign o[0] = arr[i].f[EA+:4];
    // enum constant as a bit-select index
    assign ob[0] = arr[i].f[EB];
    // package LOCALPARAM as a bound
    assign o[1] = arr[i].f[UL+:4];
    // qualified package parameter
    assign o[2] = arr[i].f[pv4::UA+:4];
    // module parameter / localparam
    assign o[3] = arr[i].f[VP+:4];
    assign o[4] = arr[i].f[VL+:4];
    // both bounds params
    assign o[5] = arr[i].f[UA+:VP];
    // cast bound
    assign o[6] = arr[i].f[int'(UA)+:4];
    // sized-literal bound
    assign o[7] = arr[i].f[32'd5+:4];
    // enum-cast bound
    assign o[8] = arr[i].f[e4_t'(EA)+:4];
  end

  assign o[16] = arr[0].f[EA+:4];
  assign o[17] = arr[0].f[UL+:4];
  assign o[18] = arr[0].f[pv4::UA+:4];
endmodule
