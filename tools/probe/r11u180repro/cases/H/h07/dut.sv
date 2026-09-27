// § enumImportParentLastWriter180
package p;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
endpackage
module z_mod import p::*; (input logic y);
endmodule
module a_mod import p::*; (input logic x);
endmodule
