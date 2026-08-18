// r10v69 arm v1 - hier_path NAME shapes the implementer's a1/a2 do NOT cover:
// LHS position, operation operand, bit-select BASE, call argument, struct
// member CHAINS, no-index paths, 3 unrollings.
package pv1;
  parameter int PA = 7;
  parameter int PB = 8;
endpackage

typedef struct packed { logic [31:0] c; logic [31:0] d; } inner_t;
typedef struct packed { inner_t x; inner_t y; } outer_t;

module v1 import pv1::*; ();
  localparam int LA = 7;
  localparam int LB = 8;
  outer_t  oarr [4];
  inner_t  iarr [4];
  logic [31:0] r [4];
  logic [7:0]  o [64];
  logic        ob [64];
  logic [31:0] wsig;

  function automatic int fv1(input logic [7:0] z); return int'(z); endfunction

  for (genvar i = 0; i < 3; i++) begin : gv1
    // 1. member CHAIN with a param ips at the tail
    assign o[0] = oarr[i].x.c[PA+:PB];
    // 2. member CHAIN with a LOCAL param ips
    assign o[1] = oarr[i].y.d[LA+:LB];
    // 3. member CHAIN, bit-select with param index
    assign ob[0] = oarr[i].x.d[PA];
    // 4. member chain, NO index at all
    assign o[2] = oarr[i].y.c;
    // 5. hier_path as an OPERATION OPERAND
    assign o[3] = iarr[i].c[PA+:PB] | iarr[i].d[LA+:LB];
    // 7. hier_path as a CALL ARGUMENT
    assign o[4] = fv1(iarr[i].c[PA+:PB]);
    // 8. hier_path on the LHS of a cont_assign
    assign oarr[i].x.c[PA+:PB] = wsig[7:0];
    // 9. LHS bit-select with param index
    assign iarr[i].d[LA] = wsig[0];
    // 10. LHS whole member
    assign iarr[i].c = wsig;
    // 11. part-select (range) with param bounds on a chain
    assign o[5] = oarr[i].y.c[PB:PA];
    // 12. ternary operands
    assign o[6] = wsig[0] ? iarr[i].c[PA+:PB] : iarr[i].d[LA+:LB];
    // 13. concat operand
    assign o[7] = {iarr[i].c[PA], iarr[i].d[LA], 6'b0};
    // 14. base index is a param, tail is a param
    assign o[8] = iarr[PA-7].c[PA+:PB];
    // 15. base index is the genvar, tail is a param, chain of 2
    assign o[9] = oarr[i].x.c[LA+:LB];
  end

  // module-body (non-gen) copies
  assign o[16] = oarr[0].x.c[PA+:PB];
  assign o[17] = oarr[0].y.d[LA+:LB];
  assign ob[8] = oarr[0].x.d[PA];
  assign o[18] = fv1(iarr[0].c[PA+:PB]);
  assign oarr[1].x.c[PA+:PB] = wsig[7:0];
endmodule
