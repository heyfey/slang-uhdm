// § enumAliasCastBindsImportCopy270
package up;
  typedef enum int {INFO, WARNING, ERROR, FATAL} sev;
  typedef sev sev_t;
endpackage
package vp;
  import up::*;
  class rep;
    function string compose(sev severity);
      sev_t st = sev_t'(severity);
      return st.name();
    endfunction
  endclass
endpackage
package wp;
  import up::*;
  class rep2;
    function int k(int x);
      return int'(sev_t'(x));
    endfunction
  endclass
endpackage
module top;
  import vp::*;
  import wp::*;
  rep r;
  rep2 r2;
endmodule
