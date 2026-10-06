// § impConcatShareSameDecl262v (two unrelated packages each declaring a concatenation parameter of one name; the module reads both qualified)
package a;
  localparam logic [3:0] A1 = 4'h1;
  localparam logic [3:0] A2 = 4'h2;
  parameter logic [7:0] X = {A1, A2};
endpackage
package b;
  localparam logic [3:0] B1 = 4'h3;
  localparam logic [3:0] B2 = 4'h4;
  parameter logic [7:0] X = {B1, B2};
endpackage
module top import a::*; import b::*; (output logic [7:0] o, output logic [7:0] p);
  assign o = a::X;
  assign p = b::X;
endmodule
