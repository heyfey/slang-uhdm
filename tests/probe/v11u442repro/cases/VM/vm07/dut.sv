// § modClassTdListing442
class C;
endclass
interface ifc;
  typedef C c_t;
  c_t h [3];
endinterface
module top;
  ifc i();
endmodule
