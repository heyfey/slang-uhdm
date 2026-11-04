// § enumAliasCastBindsImportCopy270
package up;
  typedef enum bit [1:0] {INFO, WARNING, ERROR, FATAL} sev;
  typedef sev sev_t;
endpackage
interface vif;
  import up::*;
  function automatic sev_t f(sev s);
    return sev_t'(s);
  endfunction
endinterface
module top;
  vif v();
endmodule
