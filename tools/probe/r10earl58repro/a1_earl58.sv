// r10earl58 arm a1 — THE GRID.  A gen-scope parameter read at DISTANCE 0, 1
// and 2 from its declaring generate scope, in every CONTEXT (cont_assign,
// always_ff, always_comb, always @*, initial, net-decl-assign,
// var-decl-init, function body, task body) and every POSITION (direct
// part-select left/right, part-select left inside an OPERATION, ips base
// direct/nested, ips width, bit_select index direct/nested, bare operand,
// operation operand, replication count, comparison operand, LHS select, if
// condition, case item).  LHS is ALWAYS golden.
module a1_earl58 #(parameter int unsigned MP = 8)
  (input logic clk, input logic [63:0] v, output logic [63:0] o);

  if (MP > 1) begin : g1
    localparam int unsigned L1 = 4;      // typed unsigned
    localparam int          L1s = 5;     // typed SIGNED int
    localparam              L1u = 6;     // UNTYPED
    parameter  int unsigned L1p = 7;     // gen-scope `parameter`
    localparam int unsigned L1c = MP - 1; // COMPUTED from a module param

    // ---- DISTANCE 0: L1 used in its OWN gen scope
    logic [63:0] ca_d0_psld; assign ca_d0_psld = v[L1:0];
    logic [63:0] ca_d0_pslo; assign ca_d0_pslo = v[L1-1:0];
    logic [63:0] ca_d0_psrd; assign ca_d0_psrd = v[63:L1];
    logic [63:0] ca_d0_ipsbd; assign ca_d0_ipsbd = v[L1 +: 4];
    logic [63:0] ca_d0_ipsbo; assign ca_d0_ipsbo = v[L1-1 +: 4];
    logic [63:0] ca_d0_ipswd; assign ca_d0_ipswd = v[0 +: L1];
    logic [63:0] ca_d0_bsd; assign ca_d0_bsd = v[L1];
    logic [63:0] ca_d0_bso; assign ca_d0_bso = v[L1+1];
    logic [63:0] ca_d0_bare; assign ca_d0_bare = L1;
    logic [63:0] ca_d0_opnd; assign ca_d0_opnd = (L1 + 1);
    logic [63:0] ca_d0_rep; assign ca_d0_rep = {{(L1){1'b1}},1'b0};
    logic [63:0] ca_d0_cmpo; assign ca_d0_cmpo = (v[3:0] == L1);
    logic [63:0] ff_d0_psld, ff_d0_pslo, ff_d0_psrd, ff_d0_ipsbd, ff_d0_ipsbo, ff_d0_ipswd, ff_d0_bsd, ff_d0_bso, ff_d0_bare, ff_d0_opnd, ff_d0_rep, ff_d0_cmpo;
    always_ff @(posedge clk) begin
      ff_d0_psld <= v[L1:0];
      ff_d0_pslo <= v[L1-1:0];
      ff_d0_psrd <= v[63:L1];
      ff_d0_ipsbd <= v[L1 +: 4];
      ff_d0_ipsbo <= v[L1-1 +: 4];
      ff_d0_ipswd <= v[0 +: L1];
      ff_d0_bsd <= v[L1];
      ff_d0_bso <= v[L1+1];
      ff_d0_bare <= L1;
      ff_d0_opnd <= (L1 + 1);
      ff_d0_rep <= {{(L1){1'b1}},1'b0};
      ff_d0_cmpo <= (v[3:0] == L1);
    end
    logic [63:0] cb_d0_psld, cb_d0_pslo, cb_d0_psrd, cb_d0_ipsbd, cb_d0_ipsbo, cb_d0_ipswd, cb_d0_bsd, cb_d0_bso, cb_d0_bare, cb_d0_opnd, cb_d0_rep, cb_d0_cmpo;
    always_comb begin
      cb_d0_psld = v[L1:0];
      cb_d0_pslo = v[L1-1:0];
      cb_d0_psrd = v[63:L1];
      cb_d0_ipsbd = v[L1 +: 4];
      cb_d0_ipsbo = v[L1-1 +: 4];
      cb_d0_ipswd = v[0 +: L1];
      cb_d0_bsd = v[L1];
      cb_d0_bso = v[L1+1];
      cb_d0_bare = L1;
      cb_d0_opnd = (L1 + 1);
      cb_d0_rep = {{(L1){1'b1}},1'b0};
      cb_d0_cmpo = (v[3:0] == L1);
    end
    logic [63:0] as_d0_psld, as_d0_pslo, as_d0_psrd, as_d0_ipsbd, as_d0_ipsbo, as_d0_ipswd, as_d0_bsd, as_d0_bso, as_d0_bare, as_d0_opnd, as_d0_rep, as_d0_cmpo;
    always @* begin
      as_d0_psld = v[L1:0];
      as_d0_pslo = v[L1-1:0];
      as_d0_psrd = v[63:L1];
      as_d0_ipsbd = v[L1 +: 4];
      as_d0_ipsbo = v[L1-1 +: 4];
      as_d0_ipswd = v[0 +: L1];
      as_d0_bsd = v[L1];
      as_d0_bso = v[L1+1];
      as_d0_bare = L1;
      as_d0_opnd = (L1 + 1);
      as_d0_rep = {{(L1){1'b1}},1'b0};
      as_d0_cmpo = (v[3:0] == L1);
    end
    logic [63:0] in_d0_psld, in_d0_pslo, in_d0_psrd, in_d0_ipsbd, in_d0_ipsbo, in_d0_ipswd, in_d0_bsd, in_d0_bso, in_d0_bare, in_d0_opnd, in_d0_rep, in_d0_cmpo;
    initial begin
      in_d0_psld = v[L1:0];
      in_d0_pslo = v[L1-1:0];
      in_d0_psrd = v[63:L1];
      in_d0_ipsbd = v[L1 +: 4];
      in_d0_ipsbo = v[L1-1 +: 4];
      in_d0_ipswd = v[0 +: L1];
      in_d0_bsd = v[L1];
      in_d0_bso = v[L1+1];
      in_d0_bare = L1;
      in_d0_opnd = (L1 + 1);
      in_d0_rep = {{(L1){1'b1}},1'b0};
      in_d0_cmpo = (v[3:0] == L1);
    end
    wire [63:0] nd_d0_psld = v[L1:0];
    wire [63:0] nd_d0_pslo = v[L1-1:0];
    wire [63:0] nd_d0_psrd = v[63:L1];
    wire [63:0] nd_d0_ipsbd = v[L1 +: 4];
    wire [63:0] nd_d0_ipsbo = v[L1-1 +: 4];
    wire [63:0] nd_d0_ipswd = v[0 +: L1];
    wire [63:0] nd_d0_bsd = v[L1];
    wire [63:0] nd_d0_bso = v[L1+1];
    wire [63:0] nd_d0_bare = L1;
    wire [63:0] nd_d0_opnd = (L1 + 1);
    wire [63:0] nd_d0_rep = {{(L1){1'b1}},1'b0};
    wire [63:0] nd_d0_cmpo = (v[3:0] == L1);
    logic [63:0] vd_d0_psld = v[L1:0];
    logic [63:0] vd_d0_pslo = v[L1-1:0];
    logic [63:0] vd_d0_psrd = v[63:L1];
    logic [63:0] vd_d0_ipsbd = v[L1 +: 4];
    logic [63:0] vd_d0_ipsbo = v[L1-1 +: 4];
    logic [63:0] vd_d0_ipswd = v[0 +: L1];
    logic [63:0] vd_d0_bsd = v[L1];
    logic [63:0] vd_d0_bso = v[L1+1];
    logic [63:0] vd_d0_bare = L1;
    logic [63:0] vd_d0_opnd = (L1 + 1);
    logic [63:0] vd_d0_rep = {{(L1){1'b1}},1'b0};
    logic [63:0] vd_d0_cmpo = (v[3:0] == L1);
    function automatic logic [63:0] fn_d0(input logic [63:0] v);
      logic [63:0] r; r = 0;
      r = r ^ {60'b0, v[L1:0]};
      r = r ^ {60'b0, v[L1-1:0]};
      r = r ^ {60'b0, v[63:L1]};
      r = r ^ {60'b0, v[L1 +: 4]};
      r = r ^ {60'b0, v[L1-1 +: 4]};
      r = r ^ {60'b0, v[0 +: L1]};
      r = r ^ {60'b0, v[L1]};
      r = r ^ {60'b0, v[L1+1]};
      r = r ^ {60'b0, L1};
      r = r ^ {60'b0, (L1 + 1)};
      r = r ^ {60'b0, {{(L1){1'b1}},1'b0}};
      r = r ^ {60'b0, (v[3:0] == L1)};
      return r;
    endfunction
    logic [63:0] fo_d0; assign fo_d0 = fn_d0(v);
    logic [63:0] tk_d0;
    task automatic tks_d0(input logic [63:0] v);
      tk_d0 = {60'b0, v[L1:0]};
      tk_d0 = {60'b0, v[L1-1:0]};
      tk_d0 = {60'b0, v[63:L1]};
      tk_d0 = {60'b0, v[L1 +: 4]};
      tk_d0 = {60'b0, v[L1-1 +: 4]};
      tk_d0 = {60'b0, v[0 +: L1]};
      tk_d0 = {60'b0, v[L1]};
      tk_d0 = {60'b0, v[L1+1]};
      tk_d0 = {60'b0, L1};
      tk_d0 = {60'b0, (L1 + 1)};
      tk_d0 = {60'b0, {{(L1){1'b1}},1'b0}};
      tk_d0 = {60'b0, (v[3:0] == L1)};
    endtask
    always_comb tks_d0(v);
    logic [63:0] lh_d0; logic [63:0] ic_d0;
    always_comb begin
      lh_d0 = '0; ic_d0 = '0;
      lh_d0[L1-2:0] = v[5:0];
      if (v[3:0] == L1) ic_d0 = 1;
      case (v[7:0])
        L1: ic_d0 = 2;
        default: ic_d0 = 3;
      endcase
    end

    if (MP > 2) begin : g2
      localparam int unsigned L2 = 9;
      // ---- DISTANCE 1: L1 one hop up
      logic [63:0] ca_d1_psld; assign ca_d1_psld = v[L1:0];
      logic [63:0] ca_d1_pslo; assign ca_d1_pslo = v[L1-1:0];
      logic [63:0] ca_d1_psrd; assign ca_d1_psrd = v[63:L1];
      logic [63:0] ca_d1_ipsbd; assign ca_d1_ipsbd = v[L1 +: 4];
      logic [63:0] ca_d1_ipsbo; assign ca_d1_ipsbo = v[L1-1 +: 4];
      logic [63:0] ca_d1_ipswd; assign ca_d1_ipswd = v[0 +: L1];
      logic [63:0] ca_d1_bsd; assign ca_d1_bsd = v[L1];
      logic [63:0] ca_d1_bso; assign ca_d1_bso = v[L1+1];
      logic [63:0] ca_d1_bare; assign ca_d1_bare = L1;
      logic [63:0] ca_d1_opnd; assign ca_d1_opnd = (L1 + 1);
      logic [63:0] ca_d1_rep; assign ca_d1_rep = {{(L1){1'b1}},1'b0};
      logic [63:0] ca_d1_cmpo; assign ca_d1_cmpo = (v[3:0] == L1);
      logic [63:0] ff_d1_psld, ff_d1_pslo, ff_d1_psrd, ff_d1_ipsbd, ff_d1_ipsbo, ff_d1_ipswd, ff_d1_bsd, ff_d1_bso, ff_d1_bare, ff_d1_opnd, ff_d1_rep, ff_d1_cmpo;
      always_ff @(posedge clk) begin
        ff_d1_psld <= v[L1:0];
        ff_d1_pslo <= v[L1-1:0];
        ff_d1_psrd <= v[63:L1];
        ff_d1_ipsbd <= v[L1 +: 4];
        ff_d1_ipsbo <= v[L1-1 +: 4];
        ff_d1_ipswd <= v[0 +: L1];
        ff_d1_bsd <= v[L1];
        ff_d1_bso <= v[L1+1];
        ff_d1_bare <= L1;
        ff_d1_opnd <= (L1 + 1);
        ff_d1_rep <= {{(L1){1'b1}},1'b0};
        ff_d1_cmpo <= (v[3:0] == L1);
      end
      logic [63:0] cb_d1_psld, cb_d1_pslo, cb_d1_psrd, cb_d1_ipsbd, cb_d1_ipsbo, cb_d1_ipswd, cb_d1_bsd, cb_d1_bso, cb_d1_bare, cb_d1_opnd, cb_d1_rep, cb_d1_cmpo;
      always_comb begin
        cb_d1_psld = v[L1:0];
        cb_d1_pslo = v[L1-1:0];
        cb_d1_psrd = v[63:L1];
        cb_d1_ipsbd = v[L1 +: 4];
        cb_d1_ipsbo = v[L1-1 +: 4];
        cb_d1_ipswd = v[0 +: L1];
        cb_d1_bsd = v[L1];
        cb_d1_bso = v[L1+1];
        cb_d1_bare = L1;
        cb_d1_opnd = (L1 + 1);
        cb_d1_rep = {{(L1){1'b1}},1'b0};
        cb_d1_cmpo = (v[3:0] == L1);
      end
      logic [63:0] as_d1_psld, as_d1_pslo, as_d1_psrd, as_d1_ipsbd, as_d1_ipsbo, as_d1_ipswd, as_d1_bsd, as_d1_bso, as_d1_bare, as_d1_opnd, as_d1_rep, as_d1_cmpo;
      always @* begin
        as_d1_psld = v[L1:0];
        as_d1_pslo = v[L1-1:0];
        as_d1_psrd = v[63:L1];
        as_d1_ipsbd = v[L1 +: 4];
        as_d1_ipsbo = v[L1-1 +: 4];
        as_d1_ipswd = v[0 +: L1];
        as_d1_bsd = v[L1];
        as_d1_bso = v[L1+1];
        as_d1_bare = L1;
        as_d1_opnd = (L1 + 1);
        as_d1_rep = {{(L1){1'b1}},1'b0};
        as_d1_cmpo = (v[3:0] == L1);
      end
      logic [63:0] in_d1_psld, in_d1_pslo, in_d1_psrd, in_d1_ipsbd, in_d1_ipsbo, in_d1_ipswd, in_d1_bsd, in_d1_bso, in_d1_bare, in_d1_opnd, in_d1_rep, in_d1_cmpo;
      initial begin
        in_d1_psld = v[L1:0];
        in_d1_pslo = v[L1-1:0];
        in_d1_psrd = v[63:L1];
        in_d1_ipsbd = v[L1 +: 4];
        in_d1_ipsbo = v[L1-1 +: 4];
        in_d1_ipswd = v[0 +: L1];
        in_d1_bsd = v[L1];
        in_d1_bso = v[L1+1];
        in_d1_bare = L1;
        in_d1_opnd = (L1 + 1);
        in_d1_rep = {{(L1){1'b1}},1'b0};
        in_d1_cmpo = (v[3:0] == L1);
      end
      wire [63:0] nd_d1_psld = v[L1:0];
      wire [63:0] nd_d1_pslo = v[L1-1:0];
      wire [63:0] nd_d1_psrd = v[63:L1];
      wire [63:0] nd_d1_ipsbd = v[L1 +: 4];
      wire [63:0] nd_d1_ipsbo = v[L1-1 +: 4];
      wire [63:0] nd_d1_ipswd = v[0 +: L1];
      wire [63:0] nd_d1_bsd = v[L1];
      wire [63:0] nd_d1_bso = v[L1+1];
      wire [63:0] nd_d1_bare = L1;
      wire [63:0] nd_d1_opnd = (L1 + 1);
      wire [63:0] nd_d1_rep = {{(L1){1'b1}},1'b0};
      wire [63:0] nd_d1_cmpo = (v[3:0] == L1);
      logic [63:0] vd_d1_psld = v[L1:0];
      logic [63:0] vd_d1_pslo = v[L1-1:0];
      logic [63:0] vd_d1_psrd = v[63:L1];
      logic [63:0] vd_d1_ipsbd = v[L1 +: 4];
      logic [63:0] vd_d1_ipsbo = v[L1-1 +: 4];
      logic [63:0] vd_d1_ipswd = v[0 +: L1];
      logic [63:0] vd_d1_bsd = v[L1];
      logic [63:0] vd_d1_bso = v[L1+1];
      logic [63:0] vd_d1_bare = L1;
      logic [63:0] vd_d1_opnd = (L1 + 1);
      logic [63:0] vd_d1_rep = {{(L1){1'b1}},1'b0};
      logic [63:0] vd_d1_cmpo = (v[3:0] == L1);
      function automatic logic [63:0] fn_d1(input logic [63:0] v);
        logic [63:0] r; r = 0;
        r = r ^ {60'b0, v[L1:0]};
        r = r ^ {60'b0, v[L1-1:0]};
        r = r ^ {60'b0, v[63:L1]};
        r = r ^ {60'b0, v[L1 +: 4]};
        r = r ^ {60'b0, v[L1-1 +: 4]};
        r = r ^ {60'b0, v[0 +: L1]};
        r = r ^ {60'b0, v[L1]};
        r = r ^ {60'b0, v[L1+1]};
        r = r ^ {60'b0, L1};
        r = r ^ {60'b0, (L1 + 1)};
        r = r ^ {60'b0, {{(L1){1'b1}},1'b0}};
        r = r ^ {60'b0, (v[3:0] == L1)};
        return r;
      endfunction
      logic [63:0] fo_d1; assign fo_d1 = fn_d1(v);
      logic [63:0] tk_d1;
      task automatic tks_d1(input logic [63:0] v);
        tk_d1 = {60'b0, v[L1:0]};
        tk_d1 = {60'b0, v[L1-1:0]};
        tk_d1 = {60'b0, v[63:L1]};
        tk_d1 = {60'b0, v[L1 +: 4]};
        tk_d1 = {60'b0, v[L1-1 +: 4]};
        tk_d1 = {60'b0, v[0 +: L1]};
        tk_d1 = {60'b0, v[L1]};
        tk_d1 = {60'b0, v[L1+1]};
        tk_d1 = {60'b0, L1};
        tk_d1 = {60'b0, (L1 + 1)};
        tk_d1 = {60'b0, {{(L1){1'b1}},1'b0}};
        tk_d1 = {60'b0, (v[3:0] == L1)};
      endtask
      always_comb tks_d1(v);
      logic [63:0] lh_d1; logic [63:0] ic_d1;
      always_comb begin
        lh_d1 = '0; ic_d1 = '0;
        lh_d1[L1-2:0] = v[5:0];
        if (v[3:0] == L1) ic_d1 = 1;
        case (v[7:0])
          L1: ic_d1 = 2;
          default: ic_d1 = 3;
        endcase
      end
      // ---- DISTANCE 1, the other parameter KINDS
      logic [63:0] k_s, k_u, k_p, k_c, k_mp;
      assign k_s  = v[L1s:0];
      assign k_u  = v[L1u:0];
      assign k_p  = v[L1p:0];
      assign k_c  = v[L1c:0];
      assign k_mp = v[MP:0];          // MODULE param at gen depth 2 (nested)
      logic [63:0] kp_s, kp_u, kp_p, kp_c, kp_mp;
      always_ff @(posedge clk) begin
        kp_s  <= v[L1s-1:0];
        kp_u  <= v[L1u-1:0];
        kp_p  <= v[L1p-1:0];
        kp_c  <= v[L1c-1:0];
        kp_mp <= v[MP-1:0];
        kp_s  <= v[L1s];
      end

      if (MP > 3) begin : g3
        // ---- DISTANCE 2: L1 two hops up; DISTANCE 1: L2 one hop up
        logic [63:0] ca_d2_psld; assign ca_d2_psld = v[L1:0];
        logic [63:0] ca_d2_pslo; assign ca_d2_pslo = v[L1-1:0];
        logic [63:0] ca_d2_psrd; assign ca_d2_psrd = v[63:L1];
        logic [63:0] ca_d2_ipsbd; assign ca_d2_ipsbd = v[L1 +: 4];
        logic [63:0] ca_d2_ipsbo; assign ca_d2_ipsbo = v[L1-1 +: 4];
        logic [63:0] ca_d2_ipswd; assign ca_d2_ipswd = v[0 +: L1];
        logic [63:0] ca_d2_bsd; assign ca_d2_bsd = v[L1];
        logic [63:0] ca_d2_bso; assign ca_d2_bso = v[L1+1];
        logic [63:0] ca_d2_bare; assign ca_d2_bare = L1;
        logic [63:0] ca_d2_opnd; assign ca_d2_opnd = (L1 + 1);
        logic [63:0] ca_d2_rep; assign ca_d2_rep = {{(L1){1'b1}},1'b0};
        logic [63:0] ca_d2_cmpo; assign ca_d2_cmpo = (v[3:0] == L1);
        logic [63:0] ff_d2_psld, ff_d2_pslo, ff_d2_psrd, ff_d2_ipsbd, ff_d2_ipsbo, ff_d2_ipswd, ff_d2_bsd, ff_d2_bso, ff_d2_bare, ff_d2_opnd, ff_d2_rep, ff_d2_cmpo;
        always_ff @(posedge clk) begin
          ff_d2_psld <= v[L1:0];
          ff_d2_pslo <= v[L1-1:0];
          ff_d2_psrd <= v[63:L1];
          ff_d2_ipsbd <= v[L1 +: 4];
          ff_d2_ipsbo <= v[L1-1 +: 4];
          ff_d2_ipswd <= v[0 +: L1];
          ff_d2_bsd <= v[L1];
          ff_d2_bso <= v[L1+1];
          ff_d2_bare <= L1;
          ff_d2_opnd <= (L1 + 1);
          ff_d2_rep <= {{(L1){1'b1}},1'b0};
          ff_d2_cmpo <= (v[3:0] == L1);
        end
        logic [63:0] cb_d2_psld, cb_d2_pslo, cb_d2_psrd, cb_d2_ipsbd, cb_d2_ipsbo, cb_d2_ipswd, cb_d2_bsd, cb_d2_bso, cb_d2_bare, cb_d2_opnd, cb_d2_rep, cb_d2_cmpo;
        always_comb begin
          cb_d2_psld = v[L1:0];
          cb_d2_pslo = v[L1-1:0];
          cb_d2_psrd = v[63:L1];
          cb_d2_ipsbd = v[L1 +: 4];
          cb_d2_ipsbo = v[L1-1 +: 4];
          cb_d2_ipswd = v[0 +: L1];
          cb_d2_bsd = v[L1];
          cb_d2_bso = v[L1+1];
          cb_d2_bare = L1;
          cb_d2_opnd = (L1 + 1);
          cb_d2_rep = {{(L1){1'b1}},1'b0};
          cb_d2_cmpo = (v[3:0] == L1);
        end
        logic [63:0] as_d2_psld, as_d2_pslo, as_d2_psrd, as_d2_ipsbd, as_d2_ipsbo, as_d2_ipswd, as_d2_bsd, as_d2_bso, as_d2_bare, as_d2_opnd, as_d2_rep, as_d2_cmpo;
        always @* begin
          as_d2_psld = v[L1:0];
          as_d2_pslo = v[L1-1:0];
          as_d2_psrd = v[63:L1];
          as_d2_ipsbd = v[L1 +: 4];
          as_d2_ipsbo = v[L1-1 +: 4];
          as_d2_ipswd = v[0 +: L1];
          as_d2_bsd = v[L1];
          as_d2_bso = v[L1+1];
          as_d2_bare = L1;
          as_d2_opnd = (L1 + 1);
          as_d2_rep = {{(L1){1'b1}},1'b0};
          as_d2_cmpo = (v[3:0] == L1);
        end
        logic [63:0] in_d2_psld, in_d2_pslo, in_d2_psrd, in_d2_ipsbd, in_d2_ipsbo, in_d2_ipswd, in_d2_bsd, in_d2_bso, in_d2_bare, in_d2_opnd, in_d2_rep, in_d2_cmpo;
        initial begin
          in_d2_psld = v[L1:0];
          in_d2_pslo = v[L1-1:0];
          in_d2_psrd = v[63:L1];
          in_d2_ipsbd = v[L1 +: 4];
          in_d2_ipsbo = v[L1-1 +: 4];
          in_d2_ipswd = v[0 +: L1];
          in_d2_bsd = v[L1];
          in_d2_bso = v[L1+1];
          in_d2_bare = L1;
          in_d2_opnd = (L1 + 1);
          in_d2_rep = {{(L1){1'b1}},1'b0};
          in_d2_cmpo = (v[3:0] == L1);
        end
        wire [63:0] nd_d2_psld = v[L1:0];
        wire [63:0] nd_d2_pslo = v[L1-1:0];
        wire [63:0] nd_d2_psrd = v[63:L1];
        wire [63:0] nd_d2_ipsbd = v[L1 +: 4];
        wire [63:0] nd_d2_ipsbo = v[L1-1 +: 4];
        wire [63:0] nd_d2_ipswd = v[0 +: L1];
        wire [63:0] nd_d2_bsd = v[L1];
        wire [63:0] nd_d2_bso = v[L1+1];
        wire [63:0] nd_d2_bare = L1;
        wire [63:0] nd_d2_opnd = (L1 + 1);
        wire [63:0] nd_d2_rep = {{(L1){1'b1}},1'b0};
        wire [63:0] nd_d2_cmpo = (v[3:0] == L1);
        logic [63:0] vd_d2_psld = v[L1:0];
        logic [63:0] vd_d2_pslo = v[L1-1:0];
        logic [63:0] vd_d2_psrd = v[63:L1];
        logic [63:0] vd_d2_ipsbd = v[L1 +: 4];
        logic [63:0] vd_d2_ipsbo = v[L1-1 +: 4];
        logic [63:0] vd_d2_ipswd = v[0 +: L1];
        logic [63:0] vd_d2_bsd = v[L1];
        logic [63:0] vd_d2_bso = v[L1+1];
        logic [63:0] vd_d2_bare = L1;
        logic [63:0] vd_d2_opnd = (L1 + 1);
        logic [63:0] vd_d2_rep = {{(L1){1'b1}},1'b0};
        logic [63:0] vd_d2_cmpo = (v[3:0] == L1);
        function automatic logic [63:0] fn_d2(input logic [63:0] v);
          logic [63:0] r; r = 0;
          r = r ^ {60'b0, v[L1:0]};
          r = r ^ {60'b0, v[L1-1:0]};
          r = r ^ {60'b0, v[63:L1]};
          r = r ^ {60'b0, v[L1 +: 4]};
          r = r ^ {60'b0, v[L1-1 +: 4]};
          r = r ^ {60'b0, v[0 +: L1]};
          r = r ^ {60'b0, v[L1]};
          r = r ^ {60'b0, v[L1+1]};
          r = r ^ {60'b0, L1};
          r = r ^ {60'b0, (L1 + 1)};
          r = r ^ {60'b0, {{(L1){1'b1}},1'b0}};
          r = r ^ {60'b0, (v[3:0] == L1)};
          return r;
        endfunction
        logic [63:0] fo_d2; assign fo_d2 = fn_d2(v);
        logic [63:0] tk_d2;
        task automatic tks_d2(input logic [63:0] v);
          tk_d2 = {60'b0, v[L1:0]};
          tk_d2 = {60'b0, v[L1-1:0]};
          tk_d2 = {60'b0, v[63:L1]};
          tk_d2 = {60'b0, v[L1 +: 4]};
          tk_d2 = {60'b0, v[L1-1 +: 4]};
          tk_d2 = {60'b0, v[0 +: L1]};
          tk_d2 = {60'b0, v[L1]};
          tk_d2 = {60'b0, v[L1+1]};
          tk_d2 = {60'b0, L1};
          tk_d2 = {60'b0, (L1 + 1)};
          tk_d2 = {60'b0, {{(L1){1'b1}},1'b0}};
          tk_d2 = {60'b0, (v[3:0] == L1)};
        endtask
        always_comb tks_d2(v);
        logic [63:0] lh_d2; logic [63:0] ic_d2;
        always_comb begin
          lh_d2 = '0; ic_d2 = '0;
          lh_d2[L1-2:0] = v[5:0];
          if (v[3:0] == L1) ic_d2 = 1;
          case (v[7:0])
            L1: ic_d2 = 2;
            default: ic_d2 = 3;
          endcase
        end
        logic [63:0] ca_e1_psld; assign ca_e1_psld = v[L2:0];
        logic [63:0] ca_e1_pslo; assign ca_e1_pslo = v[L2-1:0];
        logic [63:0] ca_e1_psrd; assign ca_e1_psrd = v[63:L2];
        logic [63:0] ca_e1_ipsbd; assign ca_e1_ipsbd = v[L2 +: 4];
        logic [63:0] ca_e1_ipsbo; assign ca_e1_ipsbo = v[L2-1 +: 4];
        logic [63:0] ca_e1_ipswd; assign ca_e1_ipswd = v[0 +: L2];
        logic [63:0] ca_e1_bsd; assign ca_e1_bsd = v[L2];
        logic [63:0] ca_e1_bso; assign ca_e1_bso = v[L2+1];
        logic [63:0] ca_e1_bare; assign ca_e1_bare = L2;
        logic [63:0] ca_e1_opnd; assign ca_e1_opnd = (L2 + 1);
        logic [63:0] ca_e1_rep; assign ca_e1_rep = {{(L2){1'b1}},1'b0};
        logic [63:0] ca_e1_cmpo; assign ca_e1_cmpo = (v[3:0] == L2);
        logic [63:0] ff_e1_psld, ff_e1_pslo, ff_e1_psrd, ff_e1_ipsbd, ff_e1_ipsbo, ff_e1_ipswd, ff_e1_bsd, ff_e1_bso, ff_e1_bare, ff_e1_opnd, ff_e1_rep, ff_e1_cmpo;
        always_ff @(posedge clk) begin
          ff_e1_psld <= v[L2:0];
          ff_e1_pslo <= v[L2-1:0];
          ff_e1_psrd <= v[63:L2];
          ff_e1_ipsbd <= v[L2 +: 4];
          ff_e1_ipsbo <= v[L2-1 +: 4];
          ff_e1_ipswd <= v[0 +: L2];
          ff_e1_bsd <= v[L2];
          ff_e1_bso <= v[L2+1];
          ff_e1_bare <= L2;
          ff_e1_opnd <= (L2 + 1);
          ff_e1_rep <= {{(L2){1'b1}},1'b0};
          ff_e1_cmpo <= (v[3:0] == L2);
        end
        logic [63:0] cb_e1_psld, cb_e1_pslo, cb_e1_psrd, cb_e1_ipsbd, cb_e1_ipsbo, cb_e1_ipswd, cb_e1_bsd, cb_e1_bso, cb_e1_bare, cb_e1_opnd, cb_e1_rep, cb_e1_cmpo;
        always_comb begin
          cb_e1_psld = v[L2:0];
          cb_e1_pslo = v[L2-1:0];
          cb_e1_psrd = v[63:L2];
          cb_e1_ipsbd = v[L2 +: 4];
          cb_e1_ipsbo = v[L2-1 +: 4];
          cb_e1_ipswd = v[0 +: L2];
          cb_e1_bsd = v[L2];
          cb_e1_bso = v[L2+1];
          cb_e1_bare = L2;
          cb_e1_opnd = (L2 + 1);
          cb_e1_rep = {{(L2){1'b1}},1'b0};
          cb_e1_cmpo = (v[3:0] == L2);
        end
        logic [63:0] as_e1_psld, as_e1_pslo, as_e1_psrd, as_e1_ipsbd, as_e1_ipsbo, as_e1_ipswd, as_e1_bsd, as_e1_bso, as_e1_bare, as_e1_opnd, as_e1_rep, as_e1_cmpo;
        always @* begin
          as_e1_psld = v[L2:0];
          as_e1_pslo = v[L2-1:0];
          as_e1_psrd = v[63:L2];
          as_e1_ipsbd = v[L2 +: 4];
          as_e1_ipsbo = v[L2-1 +: 4];
          as_e1_ipswd = v[0 +: L2];
          as_e1_bsd = v[L2];
          as_e1_bso = v[L2+1];
          as_e1_bare = L2;
          as_e1_opnd = (L2 + 1);
          as_e1_rep = {{(L2){1'b1}},1'b0};
          as_e1_cmpo = (v[3:0] == L2);
        end
        logic [63:0] in_e1_psld, in_e1_pslo, in_e1_psrd, in_e1_ipsbd, in_e1_ipsbo, in_e1_ipswd, in_e1_bsd, in_e1_bso, in_e1_bare, in_e1_opnd, in_e1_rep, in_e1_cmpo;
        initial begin
          in_e1_psld = v[L2:0];
          in_e1_pslo = v[L2-1:0];
          in_e1_psrd = v[63:L2];
          in_e1_ipsbd = v[L2 +: 4];
          in_e1_ipsbo = v[L2-1 +: 4];
          in_e1_ipswd = v[0 +: L2];
          in_e1_bsd = v[L2];
          in_e1_bso = v[L2+1];
          in_e1_bare = L2;
          in_e1_opnd = (L2 + 1);
          in_e1_rep = {{(L2){1'b1}},1'b0};
          in_e1_cmpo = (v[3:0] == L2);
        end
        wire [63:0] nd_e1_psld = v[L2:0];
        wire [63:0] nd_e1_pslo = v[L2-1:0];
        wire [63:0] nd_e1_psrd = v[63:L2];
        wire [63:0] nd_e1_ipsbd = v[L2 +: 4];
        wire [63:0] nd_e1_ipsbo = v[L2-1 +: 4];
        wire [63:0] nd_e1_ipswd = v[0 +: L2];
        wire [63:0] nd_e1_bsd = v[L2];
        wire [63:0] nd_e1_bso = v[L2+1];
        wire [63:0] nd_e1_bare = L2;
        wire [63:0] nd_e1_opnd = (L2 + 1);
        wire [63:0] nd_e1_rep = {{(L2){1'b1}},1'b0};
        wire [63:0] nd_e1_cmpo = (v[3:0] == L2);
        logic [63:0] vd_e1_psld = v[L2:0];
        logic [63:0] vd_e1_pslo = v[L2-1:0];
        logic [63:0] vd_e1_psrd = v[63:L2];
        logic [63:0] vd_e1_ipsbd = v[L2 +: 4];
        logic [63:0] vd_e1_ipsbo = v[L2-1 +: 4];
        logic [63:0] vd_e1_ipswd = v[0 +: L2];
        logic [63:0] vd_e1_bsd = v[L2];
        logic [63:0] vd_e1_bso = v[L2+1];
        logic [63:0] vd_e1_bare = L2;
        logic [63:0] vd_e1_opnd = (L2 + 1);
        logic [63:0] vd_e1_rep = {{(L2){1'b1}},1'b0};
        logic [63:0] vd_e1_cmpo = (v[3:0] == L2);
        function automatic logic [63:0] fn_e1(input logic [63:0] v);
          logic [63:0] r; r = 0;
          r = r ^ {60'b0, v[L2:0]};
          r = r ^ {60'b0, v[L2-1:0]};
          r = r ^ {60'b0, v[63:L2]};
          r = r ^ {60'b0, v[L2 +: 4]};
          r = r ^ {60'b0, v[L2-1 +: 4]};
          r = r ^ {60'b0, v[0 +: L2]};
          r = r ^ {60'b0, v[L2]};
          r = r ^ {60'b0, v[L2+1]};
          r = r ^ {60'b0, L2};
          r = r ^ {60'b0, (L2 + 1)};
          r = r ^ {60'b0, {{(L2){1'b1}},1'b0}};
          r = r ^ {60'b0, (v[3:0] == L2)};
          return r;
        endfunction
        logic [63:0] fo_e1; assign fo_e1 = fn_e1(v);
        logic [63:0] tk_e1;
        task automatic tks_e1(input logic [63:0] v);
          tk_e1 = {60'b0, v[L2:0]};
          tk_e1 = {60'b0, v[L2-1:0]};
          tk_e1 = {60'b0, v[63:L2]};
          tk_e1 = {60'b0, v[L2 +: 4]};
          tk_e1 = {60'b0, v[L2-1 +: 4]};
          tk_e1 = {60'b0, v[0 +: L2]};
          tk_e1 = {60'b0, v[L2]};
          tk_e1 = {60'b0, v[L2+1]};
          tk_e1 = {60'b0, L2};
          tk_e1 = {60'b0, (L2 + 1)};
          tk_e1 = {60'b0, {{(L2){1'b1}},1'b0}};
          tk_e1 = {60'b0, (v[3:0] == L2)};
        endtask
        always_comb tks_e1(v);
        logic [63:0] lh_e1; logic [63:0] ic_e1;
        always_comb begin
          lh_e1 = '0; ic_e1 = '0;
          lh_e1[L2-2:0] = v[5:0];
          if (v[3:0] == L2) ic_e1 = 1;
          case (v[7:0])
            L2: ic_e1 = 2;
            default: ic_e1 = 3;
          endcase
        end
      end : g3
    end : g2

    // ---- DISTANCE 1 in an UNNAMED generate block
    if (MP > 2) begin
      logic [63:0] un_ca; assign un_ca = v[L1-1:0];
      logic [63:0] un_ff;
      always_ff @(posedge clk) un_ff <= v[L1-1:0];
      logic [63:0] un_bs; assign un_bs = v[L1];
    end

    // ---- DISTANCE 1 in a FOR-generate (named), incl. the GENVAR
    for (genvar gi = 0; gi < 2; gi++) begin : gf
      logic [63:0] fg_ca; assign fg_ca = v[L1-1:0];
      logic [63:0] fg_bs; assign fg_bs = v[L1];
      logic [63:0] fg_gv; assign fg_gv = v[gi];
      logic [63:0] fg_gvo; assign fg_gvo = v[gi+1];
      logic [63:0] fg_ff;
      always_ff @(posedge clk) begin
        fg_ff <= v[L1-1:0];
        fg_ff <= v[L1];
        fg_ff <= v[gi];
      end
    end
  end : g1

  assign o = v;
endmodule

module top_earl58 (input logic clk, input logic [63:0] v, output logic [63:0] o1, o2);
  a1_earl58 #(.MP(8))  u1 (.clk(clk), .v(v), .o(o1));
  a1_earl58 #(.MP(12)) u2 (.clk(clk), .v(v), .o(o2));
endmodule
