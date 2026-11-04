// § enumImportParentLastWriter180
package p;
  typedef enum logic [1:0] { A, B } e_t;
endpackage
module child import p::*; (input e_t i);
endmodule
module top import p::*; ();
  e_t v;
  child u(.i(v));
endmodule
