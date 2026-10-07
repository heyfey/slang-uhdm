// § enumAliasCastBindsImportCopy270
package up;
  typedef enum bit [1:0] {INFO, WARNING, ERROR, FATAL} sev;
  typedef sev sev_t;
endpackage
package vp;
  class rep;
    function bit compose(up::sev severity);
      return up::sev_t'(severity) == up::INFO;
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
