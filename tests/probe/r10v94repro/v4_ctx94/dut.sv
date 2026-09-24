// r10v94 arm v4 -- more CONTEXTS for a cast operand in an elaborated gen-scope
// cont_assign: ternary arms, concat, replication count, a dimension bound, a
// part-select bound, an inside-expression, and a name declared AFTER the gen
// scope.  MEASUREMENT ONLY.
module chv4_94 #(parameter int unsigned W = 8) (
  input  logic [W-1:0] a_i,
  input  logic sel_i,
  output logic [W-1:0] o1,o2,o3,o4,o5,o6,o7
);
  logic [W-1:0] before_var;
  logic [W-1:0] mid_var;
  assign before_var = a_i;
  assign mid_var = a_i;

  if (W > 2) begin : gen_c
    logic [W-1:0] c_loc;
    assign c_loc = a_i;
    // ternary arms
    assign o1 = sel_i ? W'(before_var) : W'(c_loc);
    // concat + replication
    assign o2 = {W'(before_var)} ^ {1{W'(mid_var)}};
    // cast on both sides of a binary, same name twice
    assign o3 = W'(before_var) ^ W'(before_var);
    // cast inside a part-select base expression
    assign o4 = {W{1'b0}} | W'(before_var[0 +: 1]);
    // cast of a module var declared between two gen scopes
    assign o5 = W'(mid_var);
    // cast of the gen-local (own scope, must stay null)
    assign o6 = W'(c_loc);
  end

  if (W > 2) begin : gen_d
    // a SECOND gen scope reading the same names, after mid_var's declaration
    assign o7 = W'(mid_var) ^ W'(before_var);
  end
endmodule

module v4_ctx94_top (
  input logic [7:0] a8, input logic s,
  output logic [7:0] r1,r2,r3,r4,r5,r6,r7
);
  chv4_94 #(.W(8)) u_a (.a_i(a8), .sel_i(s), .o1(r1),.o2(r2),.o3(r3),.o4(r4),.o5(r5),.o6(r6),.o7(r7));
endmodule
