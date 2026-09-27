// § enumImportParentLastWriter180 (verifier: an importer function-scoped import in zmod, a wildcard body import in amod)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module zmod(input logic [1:0] x, output logic o);
  function automatic logic chk(input logic [1:0] v);
    import p::*;
    return v == B;
  endfunction
  assign o = chk(x);
endmodule
module amod(input logic [1:0] x, output logic o);
  import p::*;
  e_t s;
  assign s = e_t'(x);
  assign o = (s == C);
endmodule
module top(input logic [1:0] x, output logic y1, y2);
  zmod uz(.x(x), .o(y1));
  amod ua(.x(x), .o(y2));
endmodule
