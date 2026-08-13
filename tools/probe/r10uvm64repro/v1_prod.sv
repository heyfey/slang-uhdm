// r10uvm64 VERIFIER arm v1 — THE EMPTY PRODUCT CELLS of b3.
//
// b3_kinds.sv measures three axes ONE AT A TIME and always at the same point of
// the other two: the KIND spread is all `if`-begin + literal initialiser, the
// INITIALISER spread is all `int` + `if`-begin, the SHAPE spread is all `int` +
// literal.  The product BLOCK-SHAPE x INITIALISER x VAR-KIND was therefore
// never measured, and § blkLocalSameCtrlDepthWindowBinds64 claims all three
// axes carry NO term.  If any interaction cell disagrees with golden, the gate
// is wrong somewhere the implementer's arms cannot see.
//
// SHAPES (all put the DECL at ctrlBodyDepth28 == 1 and read it in an if
// CONDITION at ctrlBodyDepth28 == 1, i.e. the law's cell):
//   a = `if`-begin      b = `else`-begin      c = plain `begin` nested inside
//                                                 an `if`-begin (depth stays 1)
// INITIALISERS: n = none   l = literal   c = CALL   x = operation
// KINDS:        i = int    s = string    h = class handle   v = logic [7:0]
//
// Cell name: p_<shape><init>_<kind>.  48 cells.

class v1c;
  int prop;

  function automatic int getid();
    return 42;
  endfunction

  function automatic string getstr();
    return "z";
  endfunction

  function automatic v1c geth();
    return null;
  endfunction

  // ------------------------------------------------------------- shape a
  function automatic int fa(input int farg);
    int r = 0;
    if (farg == 0) begin
      int         p_an_i;
      string      p_an_s;
      v1c         p_an_h;
      logic [7:0] p_an_v;
      int         p_al_i = 1;
      string      p_al_s = "a";
      v1c         p_al_h = null;
      logic [7:0] p_al_v = 8'd1;
      int         p_ac_i = getid();
      string      p_ac_s = getstr();
      v1c         p_ac_h = geth();
      logic [7:0] p_ac_v = getid();
      int         p_ax_i = 1 + 2;
      string      p_ax_s = {"a", "b"};
      v1c         p_ax_h = (farg == 0) ? null : null;
      logic [7:0] p_ax_v = 8'd1 + 8'd2;
      if (p_an_i == 3) r = r + 1;
      if (p_an_s == "q") r = r + 1;
      if (p_an_h == null) r = r + 1;
      if (p_an_v == 8'd3) r = r + 1;
      if (p_al_i == 3) r = r + 1;
      if (p_al_s == "q") r = r + 1;
      if (p_al_h == null) r = r + 1;
      if (p_al_v == 8'd3) r = r + 1;
      if (p_ac_i == 3) r = r + 1;
      if (p_ac_s == "q") r = r + 1;
      if (p_ac_h == null) r = r + 1;
      if (p_ac_v == 8'd3) r = r + 1;
      if (p_ax_i == 3) r = r + 1;
      if (p_ax_s == "q") r = r + 1;
      if (p_ax_h == null) r = r + 1;
      if (p_ax_v == 8'd3) r = r + 1;
    end
    return r;
  endfunction

  // ------------------------------------------------------------- shape b
  function automatic int fb(input int farg);
    int r = 0;
    if (farg == 99) begin
      r = 100;
    end
    else begin
      int         p_bn_i;
      string      p_bn_s;
      v1c         p_bn_h;
      logic [7:0] p_bn_v;
      int         p_bl_i = 1;
      string      p_bl_s = "a";
      v1c         p_bl_h = null;
      logic [7:0] p_bl_v = 8'd1;
      int         p_bc_i = getid();
      string      p_bc_s = getstr();
      v1c         p_bc_h = geth();
      logic [7:0] p_bc_v = getid();
      int         p_bx_i = 1 + 2;
      string      p_bx_s = {"a", "b"};
      v1c         p_bx_h = (farg == 0) ? null : null;
      logic [7:0] p_bx_v = 8'd1 + 8'd2;
      if (p_bn_i == 3) r = r + 1;
      if (p_bn_s == "q") r = r + 1;
      if (p_bn_h == null) r = r + 1;
      if (p_bn_v == 8'd3) r = r + 1;
      if (p_bl_i == 3) r = r + 1;
      if (p_bl_s == "q") r = r + 1;
      if (p_bl_h == null) r = r + 1;
      if (p_bl_v == 8'd3) r = r + 1;
      if (p_bc_i == 3) r = r + 1;
      if (p_bc_s == "q") r = r + 1;
      if (p_bc_h == null) r = r + 1;
      if (p_bc_v == 8'd3) r = r + 1;
      if (p_bx_i == 3) r = r + 1;
      if (p_bx_s == "q") r = r + 1;
      if (p_bx_h == null) r = r + 1;
      if (p_bx_v == 8'd3) r = r + 1;
    end
    return r;
  endfunction

  // ------------------------------------------------------------- shape c
  function automatic int fc(input int farg);
    int r = 0;
    if (farg == 0) begin
      begin
        int         p_cn_i;
        string      p_cn_s;
        v1c         p_cn_h;
        logic [7:0] p_cn_v;
        int         p_cl_i = 1;
        string      p_cl_s = "a";
        v1c         p_cl_h = null;
        logic [7:0] p_cl_v = 8'd1;
        int         p_cc_i = getid();
        string      p_cc_s = getstr();
        v1c         p_cc_h = geth();
        logic [7:0] p_cc_v = getid();
        int         p_cx_i = 1 + 2;
        string      p_cx_s = {"a", "b"};
        v1c         p_cx_h = (farg == 0) ? null : null;
        logic [7:0] p_cx_v = 8'd1 + 8'd2;
        if (p_cn_i == 3) r = r + 1;
        if (p_cn_s == "q") r = r + 1;
        if (p_cn_h == null) r = r + 1;
        if (p_cn_v == 8'd3) r = r + 1;
        if (p_cl_i == 3) r = r + 1;
        if (p_cl_s == "q") r = r + 1;
        if (p_cl_h == null) r = r + 1;
        if (p_cl_v == 8'd3) r = r + 1;
        if (p_cc_i == 3) r = r + 1;
        if (p_cc_s == "q") r = r + 1;
        if (p_cc_h == null) r = r + 1;
        if (p_cc_v == 8'd3) r = r + 1;
        if (p_cx_i == 3) r = r + 1;
        if (p_cx_s == "q") r = r + 1;
        if (p_cx_h == null) r = r + 1;
        if (p_cx_v == 8'd3) r = r + 1;
      end
    end
    return r;
  endfunction
endclass

module v1_top;
  v1c h;
  int r;
  initial begin
    h = new();
    r = h.fa(0);
    r = h.fb(0);
    r = h.fc(0);
  end
endmodule
