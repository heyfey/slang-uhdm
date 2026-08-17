// h3: the remaining fences — GENERATE-BLOCK cont-assigns (taken and untaken),
// NET-DECLARATION assignments, a non-folding whole-RHS select, and the
// instance-connection regime inside an untaken branch.
module h3_sub #(parameter logic [31:0] S = 'h0)
              (input logic p, input logic [31:0] q, output logic [31:0] y);
  assign y = S ^ q ^ {31'b0, p};
endmodule

module h3_earl50 #(
  parameter int           W   = 32,
  parameter logic [W-1:0] J1  = 'h0,  // whole-RHS BIT-select that cannot fold
  parameter logic [W-1:0] J2  = 'h0,  // whole-RHS indexed PART-select that cannot fold
  parameter logic [W-1:0] J3  = 'h0,  // NET-DECL ternary CONDITION (openmsp430 shape)
  parameter logic [W-1:0] J4  = 'h0,  // NET-DECL initializer that IS the bare name
  parameter logic [W-1:0] J6  = 'h0,  // select in an instance OVERRIDE inside an UNTAKEN branch
  parameter logic [W-1:0] J7  = 'h0,  // select in a PORT CONNECTION inside an UNTAKEN branch
  parameter logic [W-1:0] J9  = 'h0,  // whole-name CA RHS inside an UNTAKEN branch
  parameter logic [W-1:0] JA  = 'h0,  // select in the CONDITION of an UNTAKEN if-generate
  parameter logic [W-1:0] JB  = 'h0,  // select in a for-generate LOOP BOUND
  parameter logic [W-1:0] JK  = 'h0,  // BARE-NAME operand of a CA inside a TAKEN if-generate
  parameter logic [W-1:0] JL  = 'h0,  // BARE-NAME operand of a CA inside a for-generate
  parameter logic [W-1:0] JM  = 'h0,  // whole-name CA RHS inside a TAKEN if-generate
  parameter logic [W-1:0] JN  = 'h0   // bare name in a PORT CONNECTION inside a TAKEN branch
) (
  input  logic         c,
  input  logic [W-1:0] n1, n2,
  output logic [W-1:0] o1, o2, ok
);
  assign o1 = {31'b0, J1[n1[2:0]]};
  assign o2 = J2[n1[2:0] +: 4] | 28'b0;
  wire [W-1:0] t3 = J3[0] ? n1[0] : n2[0];
  wire [W-1:0] t4 = J4;
  if (W > 99) begin : gen_j6
    h3_sub #(.S({24'b0, J6[7:0]})) u_j6 (.p(c), .q(n1), .y());
  end
  if (W > 99) begin : gen_j7
    h3_sub #(.S(32'h0)) u_j7 (.p(J7[0]), .q(n1), .y());
  end
  if (W > 99) begin : gen_j9
    wire [W-1:0] t9;
    assign t9 = J9;
  end
  if (JA[0] & 1'b0) begin : gen_ja
    wire [W-1:0] ta;
    assign ta = n1;
  end
  for (genvar g = 0; g < JB[3:0]; g++) begin : gen_jb
    wire [W-1:0] tb;
    assign tb = n1;
  end
  if (W > 0) begin : gen_jk
    assign ok = JK | n1;
  end
  for (genvar k = 0; k < 1; k++) begin : gen_jl
    wire [W-1:0] tl;
    assign tl = JL | n1;
  end
  if (W > 0) begin : gen_jm
    wire [W-1:0] tm;
    assign tm = JM;
  end
  if (W > 0) begin : gen_jn
    h3_sub #(.S(32'h0)) u_jn (.p(c), .q(JN), .y());
  end
endmodule
