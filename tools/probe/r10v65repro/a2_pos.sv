// v65 ARM 2 — EVERY folded-constant POSITION for the same package parameter,
// inside and outside an ELABORATED port High_conn.  The patch must move ONLY
// the ips-bound cells.  MEASUREMENT ONLY.
package pa2;
  localparam int PW = 5;
  localparam int PB = 2;
  localparam int PC = 3;
  function automatic int f2(input int x); return x + 1; endfunction
endpackage

module l2 #(parameter int LW = 5) (
  input logic [31:0] a_i, input logic [4:0] s_i, input logic b_i,
  output logic o_o);
  assign o_o = ^a_i ^ ^s_i ^ b_i;
endmodule

module a2_pos import pa2::*; (input logic [127:0] d_i, output logic [23:0] o_o);
  logic [4:0] w5; assign w5 = d_i[4:0];
  // --- inside the ELAB port High_conn
  l2 u_ipsw (.a_i(d_i[0  +: PW]),  .s_i(w5), .b_i(d_i[0]), .o_o(o_o[0]));   // ips WIDTH
  l2 u_ipsb (.a_i(d_i[PB +: 32]),  .s_i(w5), .b_i(d_i[0]), .o_o(o_o[1]));   // ips BASE
  l2 u_bsel (.a_i(d_i[31:0]),      .s_i(w5), .b_i(d_i[PB]), .o_o(o_o[2]));  // bit-select IDX
  l2 u_psel (.a_i({27'b0,d_i[PW-1:PB]}), .s_i(w5), .b_i(d_i[0]), .o_o(o_o[3])); // part-select BOUNDS
  l2 u_bare (.a_i(32'(PW)),        .s_i(w5), .b_i(d_i[0]), .o_o(o_o[4]));   // bare actual
  l2 u_oper (.a_i(32'(PW+PB)),     .s_i(w5), .b_i(d_i[0]), .o_o(o_o[5]));   // operation operand
  l2 u_cast (.a_i(32'(PW)),        .s_i(w5), .b_i(d_i[0]), .o_o(o_o[6]));   // cast operand
  l2 u_call (.a_i(32'(f2(PW))),    .s_i(w5), .b_i(d_i[0]), .o_o(o_o[7]));   // call arg
  l2 u_repl (.a_i({{PW{1'b1}},27'b0}), .s_i(w5), .b_i(d_i[0]), .o_o(o_o[8])); // replication count
  l2 #(.LW(PW)) u_pov (.a_i(d_i[31:0]), .s_i(w5), .b_i(d_i[0]), .o_o(o_o[9])); // param override
  // --- OUTSIDE the port connection: same positions in cont_assigns
  logic [4:0] c_ipsw, c_ipsb; logic c_bsel; logic [4:0] c_psel;
  logic [31:0] c_bare, c_oper, c_call, c_repl;
  assign c_ipsw = d_i[0  +: PW];
  assign c_ipsb = d_i[PB +: 5];
  assign c_bsel = d_i[PB];
  assign c_psel = d_i[PW-1:PB];
  assign c_bare = 32'(PW);
  assign c_oper = 32'(PW+PB);
  assign c_call = 32'(f2(PW));
  assign c_repl = {{PW{1'b1}},27'b0};
  // --- param_assign Rhs / range bound / case item
  localparam int L_PA = PW + 1;
  logic [PW-1:0] rng;
  assign rng = d_i[PW-1:0];
  logic [1:0] cs;
  always_comb begin
    unique case (d_i[3:0])
      PW: cs = 2'd1;
      PB: cs = 2'd2;
      default: cs = 2'd0;
    endcase
  end
  assign o_o[23:10] = {cs, ^c_ipsw, ^c_ipsb, c_bsel, ^c_psel, ^c_bare, ^c_oper,
                       ^c_call, ^c_repl, ^rng, L_PA[0], 1'b0, 1'b0};
endmodule
