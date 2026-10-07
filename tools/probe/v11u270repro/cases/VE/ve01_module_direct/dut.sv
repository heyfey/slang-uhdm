// § enumAliasCastBindsImportCopy270
package up;
  typedef enum bit [1:0] {INFO, WARNING, ERROR} sev;
  typedef sev sev_t;
endpackage
module top (input bit [1:0] s, output bit o);
  import up::*;
  sev_t v;
  always_comb begin
    v = sev_t'(s);
    o = (sev_t'(s) == INFO);
  end
endmodule
