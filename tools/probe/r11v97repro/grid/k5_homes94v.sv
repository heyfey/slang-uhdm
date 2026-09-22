// r11v97 VERIFIER arm k5 — LAW C's READING HOMES.  The implementer measured
// the `cont_assign` road and fenced the `param_assign` one.  Every OTHER home
// this emitter routes a package-parameter read through is here: a PROCEDURAL
// assignment, a module `localparam` initializer, a FUNCTION return, an
// instance PORT connection (non-parameter), a bit-select INDEX, a part-select
// RANGE bound, a CASE item, a concatenation, a conditional, and a `defparam`-
// free parameter OVERRIDE (the param_assign home again, from the caller side).
package k5p;
  localparam int CINT = (3 < 4);
  localparam int CF   = (4 < 3);
  localparam int CIDX = (0 < 1);
endpackage
module k5_sub #(parameter int SP = 0) (input logic [31:0] d, output logic [31:0] q);
  assign q = d + SP;
endmodule
module k5_homes94v (output logic [63:0] o);
  logic [31:0] dat;
  logic [7:0]  vec;
  wire signed [31:0] wCA = k5p::CINT;          // the measured cont_assign home
  logic signed [31:0] rPR;
  always_comb rPR = k5p::CINT;                 // a PROCEDURAL assignment
  localparam int LPC = k5p::CINT;              // a module localparam init
  function automatic int k5f();
    return k5p::CINT;                          // a FUNCTION return
  endfunction
  wire signed [31:0] wFN = k5f();
  wire        [31:0] q0;
  k5_sub #(.SP(k5p::CINT)) u0 (.d(dat), .q(q0));   // a PARAMETER OVERRIDE
  wire wIX = vec[k5p::CIDX];                   // a bit-select INDEX
  wire [1:0] wPS = vec[k5p::CIDX +: 2];        // a part-select RANGE bound
  wire signed [31:0] wCC = {30'd0, k5p::CIDX[1:0]};
  wire signed [31:0] wTR = k5p::CINT ? 32'd5 : 32'd6;
  logic signed [31:0] rCS;
  always_comb begin
    case (1'b1)
      1'b1: rCS = k5p::CINT;
      default: rCS = k5p::CF;
    endcase
  end
  assign dat = 32'd1;
  assign o = {wCA, rPR} ^ {LPC, wFN} ^ {q0, 31'd0, wIX} ^
             {30'd0, wPS, wCC} ^ {wTR, rCS};
endmodule
