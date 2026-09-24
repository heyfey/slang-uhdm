// ROAD B, CONT-ASSIGN holder: a non-reducible concat on a cont_assign Rhs.
package pk;
  parameter logic [1:0] C0 = 2'b00;
endpackage
module dut (output logic [15:0] o, output logic [15:0] p, output logic [1:0] q);
  assign o = { 3'b000, 11'h?, {pk::C0} };   // not reducible
  assign p = { 3'b000, 11'b0, {pk::C0} };   // reducible
  assign q = pk::C0;                         // bare reference
endmodule
