// § oobClassTdImporterClass468
// two compilation-unit classes declare this_type (cmp first in the file, then zz)
import p::*;
class cmp;
  typedef cmp this_type;
endclass
class zz;
  typedef zz this_type;
endclass
module top; cmp c; zz z; endmodule
