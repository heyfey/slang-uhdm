// § enumAliasCastBindsImportCopy270
package up;
  typedef enum bit [1:0] {INFO, WARNING, ERROR, FATAL} sev;
  typedef sev sev_t;
  class rs;
    function void f(sev s);
    endfunction
  endclass
endpackage
package vp;
  import up::*;
  class rep;
    function string compose(sev severity);
      sev_t st = sev_t'(severity);
      if (st == INFO) return "i";
      return "x";
    endfunction
  endclass
endpackage
interface vif;
  import up::*;
  import vp::*;
  rep r;
endinterface
module top;
  vif v();
endmodule
