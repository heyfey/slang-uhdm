// § impCondFlipTakenLeaf242
// The constant slots: a replication count, a dimension bound, a part-select bound, an indexed part-select width, a generate-if condition, a parameter default; an interface importer with a parameter port list beside a module.
package fp;
  parameter int WM = 4;
  parameter int LB = 2;
  parameter int W = WM == 1 ? 1 : LB;
  parameter int V = WM > 2 ? WM : 7;
endpackage
interface bus_if import fp::*; #(parameter int N = 1) ();
  logic [W-1:0] d;
  logic [V-1:0] e;
endinterface
module sub import fp::*; #(parameter int Q = W) (input logic [7:0] a, output logic [W-1:0] o, output logic [V*2-1:0] r);
  assign o = a[W-1:0];
  assign r = {V{a[1:0]}};
  if (W == 2) begin : g
    logic [V-1:0] t;
    assign t = a[0 +: V];
  end
endmodule
module top (input logic [7:0] a, output logic [1:0] o, output logic [7:0] r);
  bus_if b ();
  sub s (.a(a), .o(o), .r(r));
endmodule
