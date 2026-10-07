// § enumAliasCastBindsImportCopy270
package up;
  typedef enum bit [1:0] {INFO, WARNING, ERROR} sev;
  typedef sev sev_t;
endpackage
module a (input bit [1:0] s, output bit o);
  import up::*;
  assign o = (sev_t'(s) == WARNING);
endmodule
module b (input bit [1:0] s, output bit o);
  import up::sev_t;
  import up::ERROR;
  assign o = (sev_t'(s) == ERROR);
endmodule
module top (input bit [1:0] s, output bit x, y);
  a ua (.s(s), .o(x));
  b ub (.s(s), .o(y));
endmodule
