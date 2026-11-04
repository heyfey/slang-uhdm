// § enumImportParentLastWriter180
package p;
  typedef enum logic [1:0] { A, B } e_t;
  typedef struct packed { e_t k; logic b; } s_t;
endpackage
module z_mod import p::*; (input s_t y);
endmodule
module a_mod import p::*; (input e_t x);
endmodule
