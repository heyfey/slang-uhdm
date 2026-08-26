// r10earl95 arm g4 -- THE SELECTED-OBJECT GRID, which REFUTES r10earl94's
// candidate distinguisher ("the localparam unpacked array is un-evaluable, so
// reduceExpr bails on the SELECT").  ONE parameter (`W`, a module port
// parameter) is read from the SAME position over SEVEN different base kinds,
// at gen-scope depth 1 and again at depth 2.  If the selected object mattered,
// the rows would split by base kind; they split by DEPTH instead.
// MEASUREMENT ONLY.
module b95 #(
  parameter int unsigned W = 32
) (
  input  logic [7:0]   e_i,
  output logic [W-1:0] o_o
);
  typedef struct packed { logic [31:0] a; logic [31:0] b; } st95_t;
  localparam int unsigned KOFF = 1;
  localparam logic [63:0] LPARR [8] =                     // unpacked array of wide values
    '{ 64'h9, 64'h12, 64'h21, 64'h41, 64'h8E, 64'h108, 64'h204, 64'h402 };
  localparam int unsigned LPINT [8] = '{1,2,3,4,5,6,7,8}; // unpacked array of int
  localparam logic [63:0] LPVEC = 64'hDEAD_BEEF;          // packed parameter vector
  logic [63:0] m_net;                                     // a net
  logic [63:0] m_var;                                     // a variable
  st95_t       m_st  [4];                                 // an array of a struct
  logic [63:0] q [0:15];

  if (1) begin : h1
    assign q[0]  = LPARR[W-KOFF];        // localparam unpacked array of wide values
    assign q[1]  = LPINT[W-KOFF];        // localparam unpacked array of int
    assign q[2]  = LPVEC[W-KOFF];        // packed parameter vector
    assign q[3]  = m_net[W-KOFF];        // a net
    assign q[4]  = m_var[W-KOFF];        // a variable
    assign q[5]  = e_i[W-KOFF];          // a PORT
    assign q[6]  = m_st[1].a[W-KOFF];    // an array of a struct
    if (1) begin : h2
      assign q[7]  = LPARR[W-KOFF];
      assign q[8]  = LPINT[W-KOFF];
      assign q[9]  = LPVEC[W-KOFF];
      assign q[10] = m_net[W-KOFF];
      assign q[11] = m_var[W-KOFF];
      assign q[12] = e_i[W-KOFF];
      assign q[13] = m_st[1].a[W-KOFF];
      // OPERAND SHAPES at depth 2, same position:
      assign q[14] = m_net[W];           // bare parameter
      assign q[15] = m_net[LPARR[2][3:0]]; // a NESTED select as the index
    end
  end
  assign o_o = q[0][W-1:0] ^ q[7][W-1:0];
endmodule

module topb95;
  logic [7:0] e;
  logic [4:0] o5;
  logic [5:0] o6;
  logic [7:0] o8;
  b95 #(.W(5)) u5 (.e_i(e), .o_o(o5));
  b95 #(.W(6)) u6 (.e_i(e), .o_o(o6));
  b95 #(.W(8)) u8 (.e_i(e), .o_o(o8));
endmodule
