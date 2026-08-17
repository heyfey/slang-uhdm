// r10earl56 VERIFIER arm v6 — THE OVER-REACH HUNT.  Every shape here puts a
// gen-scope-declared parameter reference under a UHDM part_select /
// indexed_part_select PARENT in a gen-scope cont-assign WITHOUT being the
// cont-assign's own direct bound, or reaches the fold through a select path the
// fence's two parent kinds do not describe: a part_select OF THE PARAMETER as
// the bound, an unpacked-array parameter element, a struct-member select base,
// a multi-index var_select (call sites 1-2, which never set inPsBound), the
// DOWN-indexed part select, a ternary bound, a child instance inside the gen
// scope (childGen), and a gen scope under a for-generate (blkInLoop, the fold's
// own off-switch).
typedef struct packed { logic [15:0] f; logic [15:0] g; } v6_st56;

module v6_leaf56 (input logic [3:0] i, output logic [3:0] o);
  assign o = i;
endmodule

module v6_child56 #(parameter int unsigned Depth = 4)
                  (input logic [31:0] din, output logic [31:0] o);
  if (Depth != 0) begin : gen_ch
    localparam int unsigned CP = 3;
    logic [31:0] c0;
    assign c0 = {29'b0, din[0 +: CP]};       // d0 in a CHILD instance's gen scope
    assign o = c0;
  end
endmodule

module v6_sub56 #(parameter int unsigned Depth = 4)
                (input logic [31:0] din, input v6_st56 st,
                 input logic [31:0] arr [0:3], output logic [31:0] o);
  if (Depth != 0) begin : gen_o
    localparam logic [3:0]  PVEC = 4'd3;      // packed vector
    localparam int unsigned PARR [0:1] = '{3, 4};   // UNPACKED ARRAY param
    localparam int unsigned P1 = 3;
    localparam int unsigned P2 = 5;

    logic [31:0] a1,a2,a3,a4,a5,a6,a7,a8,a9;
    // a part_select OF THE PARAMETER as the bound: the ref's UHDM parent is a
    // part_select, so the fence FIRES -- but this ref is a select BASE
    assign a1 = {29'b0, din[0 +: PVEC[2:0]]};
    // an unpacked-array parameter ELEMENT as the bound (parent = bit_select)
    assign a2 = {29'b0, din[0 +: PARR[0]]};
    // a STRUCT MEMBER as the select base, param as the bound
    assign a3 = {29'b0, st.f[0 +: P1]};
    // an ARRAY ELEMENT as the select base (var_select; call sites 1-2)
    assign a4 = {29'b0, arr[2][0 +: P1]};
    // the DOWN-indexed part select
    assign a5 = {28'b0, din[P2 -: 4]};
    // a TERNARY bound
    assign a6 = {28'b0, din[0 +: (Depth != 0 ? P1 : P2)]};
    // the param on BOTH ends of a bare part_select, reversed order
    assign a7 = {28'b0, din[P2:P1]};
    // a CHILD INSTANCE inside the gen scope, with its own gen scope
    logic [31:0] co;
    v6_child56 #(.Depth(Depth)) u_ch (.din(din), .o(co));
    // a FOR-generate inside this gen scope: blkInLoop3 turns the fold OFF
    for (genvar gi = 0; gi < 2; gi++) begin : gen_lp
      logic [31:0] lp;
      assign lp = {29'b0, din[0 +: P1]};      // d1 inside a LOOP body
      localparam int unsigned LP0 = 3;
      logic [31:0] lp0;
      assign lp0 = {29'b0, din[0 +: LP0]};    // d0 inside a LOOP body
    end
    // an if-generate INSIDE the for-generate: still blkInLoop
    for (genvar gj = 0; gj < 2; gj++) begin : gen_lq
      if (Depth != 0) begin : gen_lqi
        localparam int unsigned LQ0 = 3;
        logic [31:0] lq0;
        assign lq0 = {29'b0, din[0 +: LQ0]};  // d0, under a LoopGenerate
      end
    end
    assign a8 = {29'b0, din[0 +: P1]};        // the CONTROL: plain d0 bound
    assign a9 = co;
    assign o = a1^a2^a3^a4^a5^a6^a7^a8^a9;
  end
endmodule

module v6_overreach56 (input logic [31:0] din, input v6_st56 st,
                       input logic [31:0] arr [0:3], output logic [31:0] o1);
  v6_sub56 #(.Depth(4)) u_s (.din(din), .st(st), .arr(arr), .o(o1));
endmodule
