// § pkgLateTsEarlierPkgOnly454v
interface bfm(output logic [7:0] addr);
  import mid::*;
endinterface
module top;
  logic [7:0] a;
  bfm b(.addr(a));
endmodule
