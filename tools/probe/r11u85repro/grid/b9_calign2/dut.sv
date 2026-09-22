// v11u83 b9 -- LAW B BREAK, sharper: FOUR distinct member values across four
// body-level cells, a gen region in the MIDDLE, so any index shift after the
// rotate lands a visibly WRONG value on a cell.
package pk;
  typedef struct packed {
    logic [7:0] p; logic [7:0] q; logic [7:0] r; logic [7:0] t;
  } s_t;
endpackage

interface ifc #(parameter pk::s_t C = '{p: 8'd11, q: 8'd22, r: 8'd33, t: 8'd44}) ();
  logic [31:0] w0, w1, w2, w3;
  assign w0 = C.p;
  generate
    assign w1 = C.q;
  endgenerate
  assign w2 = C.r;
  generate
    assign w3 = C.t;
  endgenerate
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w0 ^ u_if.w1 ^ u_if.w2 ^ u_if.w3;
endmodule
