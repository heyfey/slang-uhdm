// r11u74 a2 — LAW A's SIZE RULE inside a generate scope: the member TYPESPEC
// KIND x the Lhs width, the same grid § caAsmMemberSliceFold measured at
// module level (`d11`), written once at module level and once in a gen block
// so PARITY is the target and nothing more.
package p;
  typedef enum logic [1:0] { E0, E1, E2 } e_t;
  typedef struct packed {
    int unsigned iu;      // int_typespec, 32
    logic [39:0] lg;      // logic_typespec, 40
    byte         by;      // 8
    bit          b1;      // 1
    e_t          en;      // 2
  } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c;
    c.iu = x;
    c.lg = 40'h55AA55AA55;
    c.by = 8'h7E;
    c.b1 = 1'b1;
    c.en = E2;
    return c;
  endfunction
  localparam cfg_t BUILT = build(64);
endpackage
module dut #(parameter p::cfg_t FB = p::BUILT)
  (output logic [7:0]  t_iu8,  g_iu8,
   output logic [63:0] t_iu64, g_iu64,
   output logic [7:0]  t_lg8,  g_lg8,
   output logic [63:0] t_lg64, g_lg64,
   output logic [31:0] t_by32, g_by32,
   output logic [31:0] t_b132, g_b132,
   output logic [31:0] t_en32, g_en32,
   output logic [31:0] t_ps,   g_ps);
  assign t_iu8  = FB.iu[7:0] == 0 ? 8'd0 : FB.iu[7:0];   // control, not the law
  assign t_iu64 = FB.iu;
  assign t_lg8  = FB.lg;
  assign t_lg64 = FB.lg;
  assign t_by32 = FB.by;
  assign t_b132 = FB.b1;
  assign t_en32 = FB.en;
  assign t_ps[15:0] = FB.iu;                              // part-select Lhs
  if (1) begin : gb
    assign g_iu8  = FB.iu;                                // int, Lhs NARROWER
    assign g_iu64 = FB.iu;                                // int, Lhs WIDER
    assign g_lg8  = FB.lg;                                // logic, Lhs NARROWER
    assign g_lg64 = FB.lg;                                // logic, Lhs WIDER
    assign g_by32 = FB.by;                                // byte
    assign g_b132 = FB.b1;                                // bit
    assign g_en32 = FB.en;                                // enum
    assign g_ps[15:0] = FB.iu;                            // part-select Lhs
  end
  assign t_iu8 = 8'd0;
endmodule
