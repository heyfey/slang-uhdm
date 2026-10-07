// § enumAliasCastBindsImportCopy270
package up;
  typedef logic [3:0] nib;
  typedef nib nib_t;
  typedef enum logic [1:0] {A, B} e;
  typedef e e_t;
endpackage
module top (input logic [3:0] s, output logic [3:0] o, output logic p);
  import up::*;
  assign o = nib_t'(s);
  assign p = (e_t'(s[1:0]) == B);
endmodule
