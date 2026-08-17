// vsd11 vd — $unit SCOPE, entirely at $unit (slang refuses to let a PACKAGE
// reference a compilation-unit item, which is why `v6` produces no database on
// either binary).  The claim table walks compilation units at GROUP 0, ahead of
// packages and classes; a $unit CLASS is registered `work@<name>`.
class zeld;
  int q;
endclass

class zkd;
  int q;
endclass

typedef zeld unitd_t;          // $unit typedef, group 0 -> should CLAIM zeld

class acd;                     // $unit class, key "work@acd"
  typedef zeld c_t;            // group 4 -> loses to the $unit typedef
  typedef zkd  k_t;            // the only typedef naming zkd -> claims
  function void fd();
    acd::c_t v_c;              // reach OK, claim LOST
    acd::k_t v_k;              // reach OK, claim WON
    v_c = null;
    v_k = null;
  endfunction
endclass

module topvd;
  initial begin
    acd a = new();
    a.fd();
  end
endmodule
