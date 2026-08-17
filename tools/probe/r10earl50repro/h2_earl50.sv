// h2: the SECOND regime — instance parameter OVERRIDES and PORT CONNECTIONS —
// plus the ternary-condition shapes the older ablation tables recorded, re-run
// on a TYPED packed-vector parameter.  Each In is read in exactly ONE position.
module h2_sub #(parameter logic [31:0] S = 'h0)
              (input logic p, input logic [31:0] q, output logic [31:0] y);
  assign y = S ^ q ^ {31'b0, p};
endmodule

module h2_earl50 #(
  parameter int           W   = 32,
  parameter logic [W-1:0] I1  = 'h0,  // bit-sel TERNARY COND, bare-NET branches
  parameter logic [W-1:0] I2  = 'h0,  // bit-sel TERNARY COND, bit-sel branches (openmsp430)
  parameter logic [W-1:0] I3  = 'h0,  // instance override, BARE NAME       (c1.C9 control)
  parameter logic [W-1:0] I4  = 'h0,  // instance override, whole PART-SELECT
  parameter logic [W-1:0] I5  = 'h0,  // instance override, bare name inside an operation
  parameter logic [W-1:0] I6  = 'h0,  // port connection, BARE NAME
  parameter logic [W-1:0] I7  = 'h0,  // port connection, bare name inside an operation
  parameter logic [W-1:0] I8  = 'h0,  // NET-DECL initializer, part-sel operand
  parameter logic [W-1:0] I9  = 'h0,  // NET-DECL initializer, bit-sel operands
  parameter logic [W-1:0] IA  = 'h0,  // select used as the INDEX of a net's bit-select
  parameter logic [W-1:0] IB  = 'h0,  // select inside a sys-func-call operand, net beside
  parameter logic [W-1:0] IC  = 'h0,  // part-sel inside a NESTED op, outer walk passes
  parameter logic [W-1:0] ID  = 'h0,  // bit-sel in an ALWAYS block inside a TAKEN generate
  parameter logic [W-1:0] IE  = 'h0   // bit-sel operand in a cont-assign inside an UNTAKEN generate
) (
  input  logic         c,
  input  logic [W-1:0] n1, n2,
  output logic [W-1:0] o1, o2, oa, ob, oc, o5, o6, o7, oy3, oy4,
  output logic [W-1:0] rd
);
  assign o1 = I1[0] ? n1 : n2;
  assign o2 = I2[0] ? n1[0] : n2[0];
  h2_sub #(.S(I3))            u_i3 (.p(c), .q(n1), .y(oy3));
  h2_sub #(.S(I4[W-1:0]))     u_i4 (.p(c), .q(n1), .y(oy4));
  h2_sub #(.S(I5 | 32'h1))    u_i5 (.p(c), .q(n1), .y(o5));
  h2_sub #(.S(32'h0))         u_i6 (.p(c), .q(I6),          .y(o6));
  h2_sub #(.S(32'h0))         u_i7 (.p(c), .q(I7 | 32'h1),  .y(o7));
  wire [W-1:0] t8 = I8[3:0] | n1;
  wire [W-1:0] t9 = I9[0] | n1[0];
  assign oa = {31'b0, n1[IA[2:0]]};
  assign ob = $clog2(IB[3:0]) & n1;
  assign oc = (IC[3:0] | 32'h0) & 32'h1;
  if (W > 0) begin : gen_id
    always_comb rd = ID[3:0] | n1;
  end
  if (W > 99) begin : gen_ie
    wire [W-1:0] tie;
    assign tie = IE[0] | n1[0];
  end
endmodule
