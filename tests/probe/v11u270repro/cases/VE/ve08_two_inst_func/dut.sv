// § enumAliasCastBindsImportCopy270
package up;
  typedef enum bit [1:0] {INFO, WARNING, ERROR} sev;
  typedef sev sev_t;
endpackage
module sub (input bit [1:0] s, output bit o);
  import up::*;
  function automatic bit f(bit [1:0] x);
    sev_t v = sev_t'(x);
    return v == ERROR;
  endfunction
  assign o = f(s);
endmodule
module top (input bit [1:0] s, output bit a, b);
  sub u1 (.s(s), .o(a));
  sub u2 (.s(s), .o(b));
endmodule
