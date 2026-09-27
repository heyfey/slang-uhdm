// § enumImportParentLastWriter180 (r11u190: a program aprog and an interface zif import the enum and no module does; the program is connected to the interface)
package p;
  typedef enum logic [1:0] {A0, A1, A2} e_t;
endpackage
interface zif;
  import p::*;
  e_t v;
endinterface
program aprog(zif i);
  import p::*;
  e_t w;
  initial w = A1;
endprogram
module top;
  zif u();
  aprog pr(u);
endmodule
