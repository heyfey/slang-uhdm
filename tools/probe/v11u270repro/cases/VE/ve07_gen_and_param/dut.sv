// § enumAliasCastBindsImportCopy270
package up;
  typedef enum bit [1:0] {INFO, WARNING, ERROR} sev;
  typedef sev sev_t;
endpackage
module top #(parameter int K = 1) (input bit [1:0] s, output bit [1:0] o);
  import up::*;
  localparam sev_t LS = sev_t'(K);
  if (K == 1) begin : g
    assign o = sev_t'(s + 2'(LS));
  end
endmodule
