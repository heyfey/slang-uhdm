// r11u40 g3_shape40 — THE WRITTEN BOUND SHAPE, under the interface-port hop.
// One child (sh40) whose body carries ten differently-written bounds over its
// own parameter W, instantiated twice:
//   u_hop — W across the modport hop (s.CFG.BUS.DAT = 32)
//   u_mod — W from the parent's own module parameter (20)   [CONTROL]
// Distinct values per arm keep the pool multiset attributable.
package p40;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
endpackage

interface tif40 #(parameter p40::cfg_t CFG = '{BUS: '{DAT: 32}});
  logic [CFG.BUS.DAT-1:0] data;
  modport sub (input data);
endinterface

module sh40 #(parameter int unsigned W = 8) (input logic clk);
  logic [W-1:0]          a_minus1;     // SUB      -> reduceExpr vpiSubOp
  logic [W:0]            b_bare;       // a bare NAME
  logic [W+1:0]          c_plus1;      // ADD
  logic [W*2-1:0]        d_mul;        // MUL then SUB
  logic [2*W-1:0]        e_mulrev;     // the other MUL order
  logic [W/2-1:0]        f_div;        // DIV then SUB
  logic [(W>>1)-1:0]     g_shift;      // SHIFT then SUB
  logic [$clog2(W)-1:0]  h_clog2;      // a SYSTEM call then SUB
  logic [7:0]            i_lit;        // a LITERAL          [CONTROL]
  logic [W-1:0][1:0]     j_2d;         // two packed dims, the outer symbolic
  logic                  k_uns [W-1:0];// an UNPACKED range dim
  logic                  l_usz [W];    // an UNPACKED size dim
  always_ff @(posedge clk) begin
    a_minus1 <= '0; b_bare <= '0; c_plus1 <= '0; d_mul <= '0; e_mulrev <= '0;
    f_div <= '0; g_shift <= '0; h_clog2 <= '0; i_lit <= '0; j_2d <= '0;
    k_uns[0] <= '0; l_usz[0] <= '0;
  end
endmodule

module w_hop40 (input logic clk, tif40.sub s);
  sh40 #(.W(s.CFG.BUS.DAT)) u_hop (.clk(clk));
endmodule

module w_mod40 #(parameter int unsigned TW = 20) (input logic clk);
  sh40 #(.W(TW)) u_mod (.clk(clk));
endmodule

module g3_shape40 (input logic clk);
  tif40 s();
  w_hop40 u_h (.clk(clk), .s(s.sub));
  w_mod40 u_m (.clk(clk));
endmodule
