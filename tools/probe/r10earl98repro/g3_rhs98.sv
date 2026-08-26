// r10earl98 g3 -- THE Rhs SHAPE AXIS.  `writeCont_assign` takes the
// bind-and-clone path ONLY when `rhs->UhdmType() == uhdmoperation`; every other
// Rhs shape leaves the assignment (and its bindings) alone.  Every LHS below is
// a gen local whose name IS shadowed one module instance up, and every row
// carries at least one BARE gen-local ref in the Rhs so the binding is
// MEASURABLE (a select-only Rhs has no bare ref to score).
module s1leaf98 (input logic clk, input logic [3:0] a, output logic o);
  if (1) begin : gen_b
    logic [3:0] v1, v2;
    logic       vs;
    logic       s_op;      // binary operation
    logic       s_tern;    // ternary
    logic [7:0] s_cat;     // concatenation
    logic       s_un;      // unary
    logic [7:0] s_rep;     // replication
    logic [3:0] s_cast;    // a size cast
    logic       s_bare;    // a BARE ref     -> NOT an operation
    logic       s_const;   // a constant     -> NOT an operation
    logic [3:0] s_bsel;    // a bit select   -> NOT an operation
    logic [1:0] s_psel;    // a part select  -> NOT an operation
    logic [3:0] s_fc;      // a system call  -> NOT an operation
    assign s_op   = (v1 == v2);
    assign s_tern = vs ? v1[1] : v2[1];
    assign s_cat  = {v1, v2};
    assign s_un   = ~vs;
    assign s_rep  = {2{v1}};
    assign s_cast = 4'(v1);
    assign s_bare = vs;
    assign s_const = 1'b1;
    assign s_bsel = v1[0] ? v2 : v1;
    assign s_psel = v2[1:0];
    assign s_fc   = $signed(v1);
    assign o = s_op ^ s_tern ^ (^s_cat) ^ s_un ^ (^s_rep) ^ (^s_cast) ^ s_bare
             ^ s_const ^ (^s_bsel) ^ (^s_psel) ^ (^s_fc);
    always_ff @(posedge clk) begin
      v1 <= a;
      v2 <= v1;
      vs <= a[0];
    end
  end
endmodule

module g3_rhs98 (input logic clk, input logic [3:0] a, output logic o);
  logic s_op, s_tern, s_un, s_bare, s_const;
  logic [7:0] s_cat, s_rep;
  logic [3:0] s_cast, s_bsel, s_fc;
  logic [1:0] s_psel;
  assign s_op = 1'b0; assign s_tern = 1'b0; assign s_cat = '0;
  assign s_un = 1'b0; assign s_rep = '0;   assign s_bare = 1'b0;
  assign s_const = 1'b0; assign s_bsel = '0; assign s_psel = '0;
  assign s_cast = '0; assign s_fc = '0;
  s1leaf98 u_leaf (.clk(clk), .a(a), .o(o));
endmodule
