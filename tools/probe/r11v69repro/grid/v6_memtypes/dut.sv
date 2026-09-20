// v11u69 v6 — MEMBER KINDS inside a generate block.  The encoding (pass 56),
// fill width (pass 63) and `adjustSize` (W3) all compose here; every row has a
// module-level twin beside it so a generate-only divergence is visible.
package p;
  typedef struct packed { int unsigned n; } sub_t;
  typedef enum logic [3:0] { E_A = 4'd2, E_B = 4'd9 } e_t;
  typedef struct packed {
    logic [7:0]      b8;
    logic [63:0]     b64;
    logic [95:0]     b96;
    e_t              en;
    logic signed [7:0] sg;
    logic [15:0]     hx;
    sub_t            st;
  } cfg_t;
  localparam int K = 6;
  localparam cfg_t LIT = '{ b8: '1, b64: 8'd200, b96: '0, en: E_B,
                            sg: -8'sd5, hx: 16'hBEEF, st: '{n: 4} };
  typedef struct packed {
    logic [7:0]  b8;
    logic [63:0] b64;
  } dfl_t;
  localparam dfl_t DEF = '{ default: '1 };
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT, parameter p::dfl_t DF = p::DEF)
  (input  logic a_i,
   output logic [7:0]  t_b8,  g_b8,
   output logic [63:0] t_b64, g_b64,
   output logic [95:0] t_b96, g_b96,
   output logic [3:0]  t_en,  g_en,
   output logic signed [7:0] t_sg, g_sg,
   output logic [15:0] t_hx,  g_hx,
   output logic [31:0] t_st,  g_st,
   output logic [7:0]  t_d8,  g_d8,
   output logic [63:0] t_d64, g_d64);

  // MODULE-LEVEL twins (already landed by § caStructParamPatternSubst55)
  assign t_b8  = CFG.b8;
  assign t_b64 = CFG.b64;
  assign t_b96 = CFG.b96;
  assign t_en  = CFG.en;
  assign t_sg  = CFG.sg;
  assign t_hx  = CFG.hx;
  assign t_st  = CFG.st;          // member is itself a packed STRUCT
  assign t_d8  = DF.b8;           // pure `default:` fill
  assign t_d64 = DF.b64;

  if (1) begin : gm
    assign g_b8  = CFG.b8;
    assign g_b64 = CFG.b64;
    assign g_b96 = CFG.b96;
    assign g_en  = CFG.en;
    assign g_sg  = CFG.sg;
    assign g_hx  = CFG.hx;
    assign g_st  = CFG.st;
    assign g_d8  = DF.b8;
    assign g_d64 = DF.b64;
  end
endmodule
