// § oobClassTdImporterClass468
// three files: p.sv, a.sv (a compilation-unit class aaa2 with this_type), dut.sv (cmp with this_type)
import p::*;
class cmp;
  typedef cmp this_type;
endclass
module top; cmp c; aaa2 a; endmodule
