// § enumAliasCastBindsImportCopy270
package up;
  typedef enum bit [1:0] {INFO, WARNING, ERROR, FATAL} sev;
  typedef sev sev_t;
endpackage
module top;
  import up::*;
  sev_t v;
  function automatic sev_t f(sev s);
    return sev_t'(s);
  endfunction
endmodule
