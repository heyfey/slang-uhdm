// VERIFIER arm (r11v51) — ROAD B, pinning the boundary vb1 exposed: the
// elaborated PACKAGE copy folds every reducible Rhs EXCEPT a concatenation.
// Where exactly does the exception start and stop?
package pk;
  parameter logic [1:0]  C0 = 2'b00;
  parameter logic [1:0]  C3 = 2'b11;
  parameter logic [3:0]  K1 = {C0, C3};            // 2-element concat over refs
  parameter logic [3:0]  K2 = {2'b01, 2'b10};      // concat with NO reference
  parameter logic [3:0]  K3 = {2{C0}};             // REPLICATION over a ref
  parameter logic [3:0]  K4 = {C0} + 4'b0001;      // concat INSIDE a binary op
  localparam logic [3:0] K6 = {C0, C3};            // LOCALPARAM, not parameter
  parameter logic [3:0]  K7 = {{C0}, {C3}};        // nested concats
endpackage
module dut (output logic o);
endmodule
