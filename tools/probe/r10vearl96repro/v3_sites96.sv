// r10v96 adversarial arm v3 -- USE SITES of a wildcard-imported package typedef
// beside the array parameter that carries the law: a PORT type, a NET, a
// VARIABLE, a CAST target, a NESTED typedef, a FUNCTION RETURN, a class
// property, and a GENERATE-SCOPE declaration.  MEASUREMENT ONLY.
package p3s96;
  typedef logic [31:0] s_t;
  localparam s_t SARR [4] = '{ 32'h1, 32'h2, 32'h3, 32'h4 };
endpackage

module sub3s96 import p3s96::*; (input s_t i_i, output s_t o_o);   // PORT type
  assign o_o = i_i ^ SARR[0];
endmodule

class c3s96;
  typedef logic [31:0] cprop_t;
  cprop_t prop;
endclass

module m3s96 import p3s96::*; (output logic [31:0] o_o);
  typedef s_t nest_t;                          // NESTED typedef of the import
  localparam nest_t NARR [2] = '{ 32'h21, 32'h22 };
  localparam s_t MARR [2] = '{ 32'h31, 32'h32 };
  s_t   nv;                                    // NET of the imported typedef
  s_t   vv;                                    // VARIABLE (assigned in always)
  wire s_t wv;
  assign nv = MARR[0];
  assign wv = s_t'(MARR[1]);                   // CAST target
  always_comb vv = NARR[1];
  function automatic s_t f3s96(input s_t x);   // FUNCTION RETURN
    s_t loc;
    loc = x ^ SARR[1];
    return loc;
  endfunction
  logic [31:0] sy, gy;
  sub3s96 u_s (.i_i(MARR[0]), .o_o(sy));
  if (1) begin : g3blk                          // GEN-SCOPE declaration
    localparam s_t GARR [2] = '{ 32'h41, 32'h42 };
    s_t gnet;
    assign gnet = GARR[0];
    assign gy = gnet ^ GARR[1];
  end
  assign o_o = nv ^ wv ^ vv ^ sy ^ gy ^ f3s96(32'h7);
endmodule

module top3s96 (output logic [31:0] a_o);
  m3s96 u_m (.o_o(a_o));
endmodule
