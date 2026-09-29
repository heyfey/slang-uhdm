// § ppIdentEndInRebuiltText219 — second root file
`include "hdr.svh"
package q;
import p::*;
class user_c;
  cb_c cb;
  function void run(int x);
    string s;
    `HCALL(cb, ping(x))
    s = `HNAME(cb);
  endfunction
endclass
endpackage
module top;
  import q::*;
endmodule
