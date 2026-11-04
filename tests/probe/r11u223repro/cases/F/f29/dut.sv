// § tfArgScalarTdWriter223 — a pasted type name and a stringified formal
`define TY(X) X``_t
`define STR(X) `"X`"
package p;
  typedef int file_t;
  class c;
    function string set(`TY(file) f);
      return `STR(f);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  file_t v;
endmodule
