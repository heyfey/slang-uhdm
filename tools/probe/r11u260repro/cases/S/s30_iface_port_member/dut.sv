// § shadowedImportTsRefOwner260 (an implicit net and an interface-port member beside the fold)
package rp;
  localparam int OffD = 2;
endpackage
interface bi; logic [7:0] v; endinterface
module ctrl import rp::*; (bi b, output logic [1:0] q);
  localparam int OffD = 2;
  assign imp = b.v[0];
  always_comb q = b.v[1 +: OffD];
endmodule
module top;
  bi b ();
  logic [1:0] q;
  ctrl u (.b(b), .q(q));
endmodule
