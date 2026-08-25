// r10earl94 arm g5 -- the FENCES: a gen-for nested in a gen-if, an INTERFACE
// gen scope, a cast in the cont_assign LHS, a cast operand naming a parameter /
// localparam / enum const, and a name that matches NOTHING in the parent scope.
// MEASUREMENT ONLY.
interface if5_94 #(parameter int unsigned W = 8) ();
  logic [W-1:0] iv;
  logic [W-1:0] io;
  assign iv = '0;
  if (W > 2) begin : gi_if
    logic [W-1:0] il;
    assign il = iv;
    assign io = W'(iv) ^ W'(il);
  end
endinterface

package pk5_94;
  typedef enum logic [1:0] { E_A = 0, E_B = 1 } e5_t;
  localparam int unsigned PW = 5;
endpackage

module ch5_94 #(parameter int unsigned W = 8) (
  input  logic [W-1:0] a_i,
  output logic [W-1:0] e1_o, e2_o, e3_o,
  output logic [2*W-1:0] e4_o
);
  import pk5_94::*;
  localparam int unsigned LQ = 2;
  logic [W-1:0] m_var;
  logic [2*W-1:0] wide;
  assign m_var = a_i;

  // gen-for NESTED inside a gen-if: the pool is the OUTER gen block
  if (W > 2) begin : go
    logic [W-1:0] ov;
    assign ov = a_i;
    for (genvar gk = 0; gk < 2; gk++) begin : gf
      logic [W-1:0] fv;
      assign fv = a_i;
      assign e1_o = W'(ov) ^ W'(m_var) ^ W'(fv);
    end
  end
  // a cast in the cont_assign LHS side, and a name matching nothing
  if (W > 2) begin : gx
    logic [2*W-1:0] xv;
    assign xv[W-1:0] = W'(m_var);
    assign e4_o = xv;
    assign e2_o = W'(LQ) ^ W'(PW) ^ W'(E_B) ^ W'(m_var);
  end
  // a gen scope whose parent scope holds NO name of that spelling
  if (W > 2) begin : gy
    logic [W-1:0] yv;
    assign yv = a_i;
    assign e3_o = W'(yv);
  end
endmodule

module g5_fence94_top (
  input logic [7:0] a8, input logic [15:0] a16,
  output logic [7:0] u1,u2,u3, output logic [15:0] u4,
  output logic [15:0] v1,v2,v3, output logic [31:0] v4
);
  if5_94 #(.W(8)) the_if ();
  ch5_94 #(.W(8))  u_a (.a_i(a8), .e1_o(u1),.e2_o(u2),.e3_o(u3),.e4_o(u4));
  ch5_94 #(.W(16)) u_b (.a_i(a16),.e1_o(v1),.e2_o(v2),.e3_o(v3),.e4_o(v4));
endmodule
