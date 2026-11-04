// § enumAliasCastBindsImportCopy270
package up;
  typedef enum bit [1:0] {INFO, WARNING, ERROR} sev;
  typedef sev sev_t;
endpackage
module top;
  import up::*;
  class c;
    function sev_t f(int x); return sev_t'(x); endfunction
  endclass
  c h;
endmodule
