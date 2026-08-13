// r10uvm70 arm a2 — the SITE axis: the same implicit-plus-signing spelling at
// every declaration site that accepts it, so the law's reach is measured and
// not assumed.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
module a2 (
  input  unsigned      p_in_u,      // line 5   ANSI port, implicit + signing
  input  signed        p_in_s,      // line 6
  input  unsigned [3:0] p_in_ur,    // line 7
  output signed        p_out_s,     // line 8
  input  logic unsigned p_lg_u,     // line 9   explicit-base control
  input                 p_plain     // line 10  fully implicit control
);
  // --- MODULE-scope variables ---
  var unsigned   mv_u;              // line 13
  var signed     mv_s;              // line 14
  var unsigned [3:0] mv_ur;         // line 15
  logic unsigned mv_lg_u;           // line 16  explicit-base control
  logic          mv_plain;          // line 17
  wire signed    nw_s;              // line 18  a NET, not a var
  wire unsigned  nw_u;              // line 19

  // --- SUBROUTINE body locals and FORMALS ---
  function void g_formals(input unsigned a_u,      // line 22
                          input signed   a_s,      // line 23
                          input unsigned [3:0] a_ur, // line 24
                          input logic unsigned a_lg); // line 25
    var unsigned   l_u;             // line 26
    var signed     l_s;             // line 27
    var unsigned [3:0] l_ur;        // line 28
    logic unsigned l_lg_u;          // line 29
    begin
      var unsigned b_u;             // line 31  block local
      b_u = 1'b0;
      l_u = b_u;
    end
    l_s = 1'b0; l_ur = 4'd0; l_lg_u = 1'b0;
  endfunction

  // --- a TASK's locals (no return var at all) ---
  task t_locals;
    var unsigned tl_u;              // line 40
    tl_u = 1'b0;
  endtask

  assign p_out_s = p_in_s;
endmodule
