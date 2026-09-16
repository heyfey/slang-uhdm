// ROAD B: does the producer SUBSTITUTE a leaf ref_obj by its constant value
// inside a PACKAGE parameter's expression?  Three cells, one package:
//   R (whole expression REDUCIBLE), X (whole expression NOT reducible: 'h?),
//   S (the bare reference alone).
package pk;
  parameter logic [1:0] C0 = 2'b00;
  parameter logic [1:0] C3 = 2'b11;
  parameter logic [15:0] R = { 3'b000, 11'b0,  {C0} };   // all-constant concat
  parameter logic [15:0] X = { 3'b000, 11'h?,  {C0} };   // carries an X digit
  parameter logic [1:0]  S = C3;                          // bare reference
  parameter logic [15:0] Y = { 3'b010, 11'h?,  C0 };
endpackage
module dut (output logic o);
  assign o = ^{pk::R[0], pk::X[0], pk::S[0], pk::Y[0]};
endmodule
