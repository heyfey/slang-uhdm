// r10vearl115 ADVERSARIAL ARM va4 -- THE NAMESAKE-FENCE AXIS.  MEASUREMENT ONLY.
//
// r10earl115's namesake fence is `Scope::find(name)` on every enclosing
// InstanceBody, climbing through `parentInstance` past the module boundary.
// `find` answers ANY member of that scope, not only a variable / net / port,
// so a namesake that is a PARAMETER, a FUNCTION, a MODULE INSTANCE or a
// GENERATE-BLOCK LABEL trips it too.  r10vearl113's `v6_name113` only carries
// variable / net / port namesakes.  These cells ask what golden does for the
// other kinds -- an over-applied fence is a STILLWRONG (safe), an
// under-applied one is an AWAY.
//
//   d1  namesake is a module-scope PARAMETER
//   d2  namesake is a module-scope FUNCTION
//   d3  namesake is a MODULE INSTANCE name
//   d4  namesake is a GENERATE-BLOCK LABEL at module scope
//   d5  namesake is a module-scope VARIABLE in the module ABOVE (the a7 shape,
//       re-cut here with NO namesake in this module at all)
//   d6  namesake exists only in an UNRELATED sibling module -- must NOT fence
package v115n;
  typedef enum logic [2:0] { OpA = 3'h0, OpB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_op;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module vn_leaf115 (input logic a, output logic y);
  assign y = a;
endmodule

module vn_sib115 #(parameter int M = 3) (
  input  v115n::h2d_t tl_h_i [M],
  input  logic [7:0]  d_i,
  output logic        y_o
);
  // the sibling that OWNS the d6 name -- it must not reach the child below.
  v115n::h2d_t d6_t;
  assign d6_t = '{ a_valid: tl_h_i[0].a_valid,
                   a_op:    tl_h_i[0].a_op,
                   a_data:  d_i };
  assign y_o = d6_t.a_valid;
endmodule

module vn_child115 #(parameter int M = 3) (
  input  v115n::h2d_t tl_h_i [M],
  input  logic [7:0]  d_i,
  output logic        y_o
);
  // d1 -- a PARAMETER namesake of the gen-local target.
  localparam int d1_t = 7;
  // d2 -- a FUNCTION namesake.
  function automatic logic d2_t(input logic a);
    return a;
  endfunction
  // d3 -- a MODULE INSTANCE namesake.
  logic d3_y;
  vn_leaf115 d3_t (.a(tl_h_i[0].a_valid), .y(d3_y));
  // d4 -- a GENERATE-BLOCK LABEL namesake.
  if (M > 0) begin : d4_t
    logic unused_d4;
    assign unused_d4 = 1'b0;
  end

  for (genvar i = 0; i < M; i++) begin : gen_d1
    v115n::h2d_t d1_t;
    assign d1_t = '{ a_valid: tl_h_i[i].a_valid,
                     a_op:    tl_h_i[i].a_op,
                     a_data:  d_i };
  end
  for (genvar i = 0; i < M; i++) begin : gen_d2
    v115n::h2d_t d2_t;
    assign d2_t = '{ a_valid: tl_h_i[i].a_valid,
                     a_op:    tl_h_i[i].a_op,
                     a_data:  d_i };
  end
  for (genvar i = 0; i < M; i++) begin : gen_d3
    v115n::h2d_t d3_t;
    assign d3_t = '{ a_valid: tl_h_i[i].a_valid,
                     a_op:    tl_h_i[i].a_op,
                     a_data:  d_i };
  end
  for (genvar i = 0; i < M; i++) begin : gen_d4
    v115n::h2d_t d4_t;
    assign d4_t = '{ a_valid: tl_h_i[i].a_valid,
                     a_op:    tl_h_i[i].a_op,
                     a_data:  d_i };
  end
  // d5 -- the namesake lives in the PARENT module only.
  for (genvar i = 0; i < M; i++) begin : gen_d5
    v115n::h2d_t d5_t;
    assign d5_t = '{ a_valid: tl_h_i[i].a_valid,
                     a_op:    tl_h_i[i].a_op,
                     a_data:  d_i };
  end
  // d6 -- the namesake lives in an UNRELATED sibling module only.
  for (genvar i = 0; i < M; i++) begin : gen_d6
    v115n::h2d_t d6_t;
    assign d6_t = '{ a_valid: tl_h_i[i].a_valid,
                     a_op:    tl_h_i[i].a_op,
                     a_data:  d_i };
  end

  assign y_o = gen_d1[0].d1_t.a_valid ^ gen_d2[0].d2_t.a_valid ^
               gen_d3[0].d3_t.a_valid ^ gen_d4[0].d4_t.a_valid ^
               gen_d5[0].d5_t.a_valid ^ gen_d6[0].d6_t.a_valid ^ d3_y;
endmodule

module va4_name115 #(parameter int M = 3) (
  input  logic        clk,
  input  v115n::h2d_t tl_h_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  // the PARENT-module namesake for d5.
  v115n::h2d_t d5_t;
  assign d5_t = '{ a_valid: tl_h_i[0].a_valid,
                   a_op:    tl_h_i[0].a_op,
                   a_data:  d_i };

  logic y_c, y_s;
  vn_child115 #(.M(M)) u_c (.tl_h_i(tl_h_i), .d_i(d_i), .y_o(y_c));
  vn_sib115   #(.M(M)) u_s (.tl_h_i(tl_h_i), .d_i(d_i), .y_o(y_s));

  assign v_o = y_c ^ y_s ^ d5_t.a_valid ^ clk;
endmodule
