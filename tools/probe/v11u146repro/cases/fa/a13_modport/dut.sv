// § tfArgTypedefLastWriter146
package p; typedef enum logic {A, B} e_t; endpackage
interface ifc;
  import p::*;
  function automatic logic isb(e_t x); return x == B; endfunction
  modport mp(import isb);
endinterface
module top(output logic o);
  ifc u(); assign o = u.isb(p::A);
endmodule
