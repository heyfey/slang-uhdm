// r10earl101 g3_site101 -- USE SITES for a package scalar typedef under a
// packed dimension.  Axis: port / net / variable / parameter / cast target /
// a NESTED typedef / a function return / a struct member.  Only the PORT site
// is the law's; every other site here is a MUST-NOT-MOVE control, and each is
// owned by a law already in the tree (LAW S's variable arm, the NET half,
// ParamEmit's element clone, castPkgTdCloneViewTs123, the typespec_member arm).
package p3s101;
  typedef logic [7:0] b_t;
  typedef b_t [3:0]   bv_t;      // a NESTED typedef: a vector OF the typedef
endpackage

module m3sub101
  import p3s101::*;
(
  input  b_t [3:0] i_port,       // <- THE LAW'S SITE
  output b_t [3:0] o_port,
  input  bv_t      i_nested,     // the nested typedef, no written dim
  output logic     o_any
);
  b_t [3:0] n_net;               // a NET of the vector shape
  assign n_net = i_port;
  assign o_port = n_net;

  b_t [3:0] v_var;               // a VARIABLE of the vector shape
  always_comb v_var = n_net;

  localparam b_t [3:0] P_ARR = '{8'h1, 8'h2, 8'h3, 8'h4};   // a PARAMETER

  typedef b_t [1:0] loc_t;       // a MODULE-LOCAL nested typedef
  loc_t l_sig;
  assign l_sig = n_net[1:0];

  typedef struct packed { b_t [1:0] m; logic f; } s3_t;      // a STRUCT MEMBER
  s3_t s_sig;
  assign s_sig = '{m: l_sig, f: 1'b0};

  function automatic b_t [1:0] f3 (input b_t [1:0] a);       // RETURN + FORMAL
    b_t [1:0] loc;
    loc = a;
    return loc;
  endfunction

  logic [15:0] castd;
  assign castd = 16'(v_var[1:0]);                            // a CAST TARGET
  assign o_any = ^{P_ARR, l_sig, s_sig, f3(l_sig), castd, i_nested};
endmodule

module g3_site101 (input logic clk);
  p3s101::b_t [3:0] w_i, w_o;
  p3s101::bv_t      w_n;
  logic             w_any;
  m3sub101 u_s (.i_port(w_i), .o_port(w_o), .i_nested(w_n), .o_any(w_any));
endmodule
