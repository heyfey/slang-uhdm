// § enumImportParentLastWriter180 (r11u190: an interface imports only an enum LITERAL; another interface imports the enum typedef)
package p;
  typedef enum logic [1:0] {C0, C1, C2} e_t;
endpackage
interface zif;
  import p::C1;
  logic [1:0] v;
  assign v = C1;
endinterface
interface aif;
  import p::e_t;
  e_t w;
endinterface
module top;
  aif ua();
  zif uz();
endmodule
