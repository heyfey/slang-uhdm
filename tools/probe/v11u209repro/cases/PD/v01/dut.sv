// § pdTsNotTypedefListing209v: an implicit-type port declaration redeclared with a typedef of the same width (the typedef listing stays at its declaration)
typedef logic [7:0] my_t;
interface ifc (o);
  output [7:0] o;
  my_t o;
  assign o = 8'h5a;
endinterface
module top(output logic [7:0] y);
  my_t z;
  assign z = 8'h1;
  ifc i (.o(y));
endmodule
