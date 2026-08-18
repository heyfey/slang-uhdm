// r10rgg12 ABLATION: which const-function body shape makes Surelog's ExprEval
// give up on a localparam initializer, so that a RANGE BOUND reading that
// localparam keeps the call instead of folding?
module red #(parameter int N = 4)();
  // the packed-2D producer (rggen's get_sub_n_list / grid's f_while)
  function automatic bit [3:0][15:0] mk(int n);
    bit [3:0][15:0] list;
    int idx;
    bit [15:0] cur;
    list = '0;
    idx  = 0;
    cur  = 16'(n);
    while (cur > 0) begin
      if (cur >= 4) list[idx] = 4;
      else          list[idx] = cur;
      cur -= list[idx];
      idx += 1;
    end
    return list;
  endfunction
  localparam bit [3:0][15:0] SUBL = mk(N);

  // A: rggen's get_next_n exactly: += of a ternary over a select of the FORMAL
  function automatic int a_formal_tern(bit [3:0][15:0] a);
    int acc; acc = 0;
    for (int i = 0;i < 4;++i) acc += ((a[i] != 0) ? 1 : 0);
    return acc;
  endfunction
  // B: same, but the select is on a LOCAL the function itself wrote
  function automatic int b_local_tern(int n);
    bit [3:0][15:0] loc; int acc;
    loc = '0; acc = 0;
    for (int i = 0;i < 4;++i) loc[i] = 16'(i);
    for (int i = 0;i < 4;++i) acc += ((loc[i] != 0) ? 1 : 0);
    return acc;
  endfunction
  // C: select of the FORMAL, no ternary, non-Add operand context
  function automatic int c_formal_cmp(bit [3:0][15:0] a);
    int acc; acc = 0;
    for (int i = 0;i < 4;++i) acc += ((a[i] != 0) ? 1 : 0) + 0;
    return acc;
  endfunction
  // D: select of the FORMAL in a PLAIN Add context (no comparison, no ternary)
  function automatic int d_formal_add(bit [3:0][15:0] a);
    int acc; acc = 0;
    for (int i = 0;i < 4;++i) acc += 32'(a[i]);
    return acc;
  endfunction
  // E: select of the FORMAL under a ternary, returning a PACKED-2D value
  function automatic bit [3:0][15:0] e_formal_tern_p2d(bit [3:0][15:0] a);
    bit [3:0][15:0] o;
    o = '0;
    for (int i = 0;i < 4;++i) o[i] = ((a[i] != 0) ? 16'd1 : 16'd0);
    return o;
  endfunction
  // F: int return, no formal select at all, but a local select under a ternary
  function automatic int f_int_plain(int n);
    int acc; acc = 0;
    for (int i = 0;i < 4;++i) acc += ((i != 0) ? 1 : 0);
    return acc;
  endfunction
  // G: rggen's get_offset_list: packed-2D formal read with i-1 index, packed-2D return
  function automatic bit [3:0][15:0] g_offsets(bit [3:0][15:0] a);
    bit [3:0][15:0] o;
    for (int i = 0;i < 4;++i) begin
      if (i == 0) o[i] = 0;
      else        o[i] = a[i-1] + o[i-1];
    end
    return o;
  endfunction

  localparam int PA = a_formal_tern(SUBL);
  localparam int PB = b_local_tern(N);
  localparam int PC = c_formal_cmp(SUBL);
  localparam int PD = d_formal_add(SUBL);
  localparam bit [3:0][15:0] PE = e_formal_tern_p2d(SUBL);
  localparam int PF = f_int_plain(N);
  localparam bit [3:0][15:0] PG = g_offsets(SUBL);

  logic [PA-1:0] va;  logic [PB-1:0] vb;  logic [PC-1:0] vc;
  logic [PD-1:0] vd;  logic [PE-1:0] ve;  logic [PF-1:0] vf;
  logic [PG-1:0] vg;  logic [SUBL-1:0] vs;
  always_comb begin
    va='0; vb='0; vc='0; vd='0; ve='0; vf='0; vg='0; vs='0;
  end
endmodule

module top;
  red #(.N(4)) u_a ();
  red #(.N(6)) u_b ();
endmodule
