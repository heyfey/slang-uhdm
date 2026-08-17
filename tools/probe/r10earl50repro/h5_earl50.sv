// h5: the TRANSITIVE axis h1.H5 could not see, and the one the
// BlackParrotComplex canary lives on.  Every Ln is read ONLY by a select
// inside ANOTHER parameter's initializer; the cells differ only in what that
// other parameter is itself used for.
module h5_sub #(parameter logic [31:0] S = 'h0) (output logic [31:0] y);
  assign y = S;
endmodule

module h5_earl50 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] L1 = 'h1,  // carrier read in a GENERATE CONDITION
  parameter logic [W-1:0] L2 = 'h1,  // carrier read in a CONT-ASSIGN
  parameter logic [W-1:0] L3 = 'h1,  // carrier read NOWHERE            (h1.H5)
  parameter logic [W-1:0] L4 = 'h1,  // carrier read in a PROCEDURAL block
  parameter logic [W-1:0] L5 = 'h1,  // carrier read through a SECOND hop
  parameter logic [W-1:0] L6 = 'h1,  // carrier read in an INSTANCE OVERRIDE
  parameter logic [W-1:0] L7 = 'h1,  // selected in a NET's declared RANGE
  parameter logic [W-1:0] L8 = 'h1   // carrier read only in an INITIAL block
) (
  input  logic [W-1:0] n,
  output logic [W-1:0] o2, o6
);
  localparam logic [W-1:0] L1D = {24'b0, L1[7:0]};
  localparam logic [W-1:0] L2D = {24'b0, L2[7:0]};
  localparam logic [W-1:0] L3D = {24'b0, L3[7:0]};
  localparam logic [W-1:0] L4D = {24'b0, L4[7:0]};
  localparam logic [W-1:0] L5A = {24'b0, L5[7:0]};
  localparam logic [W-1:0] L5B = L5A + 1;
  localparam logic [W-1:0] L6D = {24'b0, L6[7:0]};
  localparam logic [W-1:0] L8D = {24'b0, L8[7:0]};

  logic [W-1:0] r4;
  wire  [L7[3:0]:0] w7;
  assign w7 = '0;

  if (L1D > 0) begin : gen_l1
    wire [W-1:0] t1;
    assign t1 = n;
  end
  assign o2 = L2D | n;
  always_comb r4 = L4D | n;
  if (L5B > 0) begin : gen_l5
    wire [W-1:0] t5;
    assign t5 = n;
  end
  h5_sub #(.S(L6D)) u_l6 (.y(o6));
  initial begin
    $display("%d", L8D);
  end
endmodule
