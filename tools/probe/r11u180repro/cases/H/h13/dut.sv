// § enumImportParentLastWriter180
package p;
  typedef enum logic [1:0] { A, B } e_t;
endpackage
module a_mod import p::*; (input logic x);
endmodule
interface z_if; import p::*; logic y; endinterface
