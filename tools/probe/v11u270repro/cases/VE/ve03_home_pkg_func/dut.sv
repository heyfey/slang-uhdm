// § enumAliasCastBindsImportCopy270
package up;
  typedef enum bit [1:0] {INFO, WARNING, ERROR} sev;
  typedef sev sev_t;
  function automatic sev_t f(bit [1:0] s);
    return sev_t'(s);
  endfunction
  class c;
    function sev_t g(int s); return sev_t'(s); endfunction
  endclass
endpackage
module top (input bit [1:0] s, output bit o);
  import up::*;
  assign o = (f(s) == INFO);
endmodule
