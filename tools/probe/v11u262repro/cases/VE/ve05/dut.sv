// § impConcatShareSameDecl262v (an interface imports two unrelated packages with a concatenation parameter of one name)
package a;
  localparam logic [3:0] A1 = 4'h1;
  parameter logic [7:0] X = {A1, 4'h2};
endpackage
package b;
  localparam logic [3:0] B1 = 4'h3;
  parameter logic [7:0] X = {B1, 4'h4};
endpackage
interface ifc;
  import a::*; import b::*;
  logic [7:0] v;
  assign v = a::X ^ b::X;
endinterface
module top(output logic [7:0] o);
  ifc i();
  assign o = i.v;
endmodule
