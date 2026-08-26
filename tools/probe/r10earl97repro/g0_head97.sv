// r10earl97 g0 -- THE HEAD REPRO.  Fifteen lines that reproduce the Earlgrey
// testflags head EXACTLY, at the SAME source shape as prim_packer.sv:31: a
// TYPED module-body localparam with a COMPUTED default, used as a BARE
// `PtrW'(x)` cast width, in a submodule that is instantiated.  On the pristine
// binary uhdm-cmp names the int_typespec at the localparam's `int` keyword --
// vpiSigned 1 on the golden side, unset on ours, same vpiExpr ref_obj, same
// bound parameter.  ONE head, and it is the corpus head in miniature.
module top97;
  logic [7:0] q;
  sub97 #(.InW(8), .OutW(8)) u_s (.q(q));
endmodule

module sub97 #(
  parameter int InW = 32,
  parameter int OutW = 32
) (output logic [7:0] q);
  localparam int Width = InW + OutW;
  localparam int PtrW = $clog2(Width+1);
  logic [PtrW-1:0] pos;
  logic [3:0] m;
  assign q = 8'(pos + PtrW'(m));
endmodule
