// a7: multi-declarator lists, '?' digits, ports, modports, arrays, replication
package a7_pkg;
  parameter M_A = 'h1, M_B = 'h2, M_C = 'b11;
  localparam M_D = 'o3, M_E = 'd4;
  parameter M_Q = 'b1?01;
  parameter M_W = 'h4;
  parameter logic [M_W-1:0] M_VEC = 'h5;
endpackage
interface a7_if;
  parameter I_W = 'h6;
  logic [7:0] d;
  modport mp (input d);
endinterface
module a7_sub #(parameter S_P = 'h7) (input logic clk);
  localparam S_L = 'h8;
  logic [S_P-1:0] r;
  initial $display(S_L, r);
endmodule
module a7_top (input logic clk);
  import a7_pkg::*;
  a7_if i0();
  a7_sub #(.S_P('h9)) s0 (.clk(clk));
  a7_sub             s1 (.clk(clk));
  localparam T_R = {2{'h3}};
  initial $display(M_A, M_B, M_C, M_D, M_E, M_Q, M_VEC, i0.I_W, T_R);
endmodule
