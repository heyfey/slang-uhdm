// r10earl52 verifier v2 — the arms a1..a4 did NOT reach:
//  (a) adjustSize's BIN *Logic-truncate* arm (source WIDER than a logic
//      target), which no arm has exercised on a declared initializer;
//  (b) an `int` target NARROWER than the source (the Int arm's min() leg);
//  (c) generate-scope and nested-instance localparams;
//  (d) an interface's localparams;
//  (e) a function-scope localparam (must stay untouched: funcScope gate).
interface v2if_earl52 ();
  localparam int F_int = 1'b1;
  localparam logic [3:0] F_lv = 8'b10101011;
endinterface

module v2sub_earl52 #(parameter bit UP = 1'b0) ();
  localparam int  N_int  = UP ? 1'b0 : 1'b1;
  localparam int  N_h    = 4'h8;
endmodule

module v2_earl52 ();
  v2if_earl52 u_if ();
  v2sub_earl52 u_a ();
  v2sub_earl52 #(.UP(1'b1)) u_b ();

  // (a) BIN wider than a LOGIC target -> adjustSize truncates from the LEFT
  localparam logic [3:0] W_l4  = 8'b10101011;
  localparam logic [3:0] W_l4b = 8'b00001011;
  localparam logic [1:0] W_l2  = 4'b1101;
  localparam bit   [3:0] W_b4  = 8'b10101011;   // bit: NO adjustSize arm
  // (b) an `int`-family target NARROWER than the source
  localparam byte        W_by  = 16'b1000000000000001;
  localparam shortint    W_sh  = 32'b1000_0000_0000_0000_0000_0000_0000_0001;
  // HEX wider than the target
  localparam logic [3:0] W_h4  = 8'hab;
  localparam byte        W_h8  = 16'hbeef;

  // (c) generate scope
  generate
    if (1) begin : g1
      localparam int  G_int = 1'b1;
      localparam int  G_h   = 4'h8;
      for (genvar i = 0; i < 2; i++) begin : g2
        localparam int G_loop = 1'b1;
      end
    end
  endgenerate

  // (e) function-scope localparam
  function automatic int f_v2(input int x);
    localparam int FS_int = 1'b1;
    return x + FS_int;
  endfunction
  localparam int USE_F = f_v2(0);
endmodule
