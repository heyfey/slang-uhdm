// § oobClassTdImporterClass468
// two compilation-unit classes declare this_type (zz first in the file, then cmp)
import p::*;
class zz;
  typedef zz this_type;
endclass
class cmp;
  typedef cmp this_type;
endclass
module top; cmp c; zz z; endmodule
