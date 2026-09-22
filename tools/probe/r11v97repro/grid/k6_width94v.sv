// r11v97 VERIFIER arm k6 — THE SHARED ROAD.  `red72Int64` is read by
// ParamEmit, ModuleEmit and ExprEmit for WIDTHS, RANGES and SELECTS as well as
// for folds, and LAW A adds an arm to it.  This arm puts an unbased-unsized
// literal (and a chain over one) underneath every one of those readers: a net
// RANGE bound, a packed dimension, an indexed part-select width, a bit-select
// INDEX, a replication count and a `$bits` argument — with the same shapes
// over a plain decimal as the live control.
package k6p;
  localparam int W1  = '1 - 4294967288;   // digit road: 1-4294967288 vs 7
  localparam int W2  = 8 - 1;             // the control, same store
  localparam int WM  = '1 * 2;            // the chain's source
  localparam int WMC = WM - 8589934588;   // a chain over it
  localparam int R1  = '1 - 4294967293;   // store 2
endpackage
module k6_width94v (output logic [63:0] o);
  logic [15:0] vv;
  wire [k6p::W1:0]  wa;                   // a net RANGE bound
  wire [k6p::W2:0]  wb;                   // the control
  logic [k6p::W1:0] pk;                   // a packed dimension
  wire [1:0] ws = vv[k6p::R1 +: 2];       // an indexed part-select base
  wire       wi = vv[k6p::R1];            // a bit-select INDEX
  wire [3:0] wr = {2{k6p::R1[1:0]}};      // a replication count's neighbour
  wire signed [31:0] wBT = $bits(pk);
  wire signed [31:0] wW1 = k6p::W1;
  wire signed [31:0] wW2 = k6p::W2;
  wire signed [31:0] wWM = k6p::WM;
  wire signed [31:0] wWMC = k6p::WMC;
  wire signed [31:0] wR1 = k6p::R1;
  assign wa = '0;
  assign wb = '0;
  assign pk = '0;
  assign vv = 16'd0;
  assign o = {wW1, wW2} ^ {wWM, wWMC} ^ {wR1, wBT} ^
             {26'd0, ws, wi, wr, 24'd0, 8'd0};
endmodule
