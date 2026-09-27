// § enumImportParentLastWriter180 § enumImpDefOwner180v (r11u190: two interfaces only; zif explicitly imports the package's STRUCT typedef, aif explicitly imports the enum)
package p;
  typedef enum logic [1:0] {K0, K1, K2} e_t;
  typedef struct packed { logic [1:0] a; } s_t;
endpackage
interface zif;
  import p::s_t;
  s_t v;
endinterface
interface aif;
  import p::e_t;
  e_t w;
endinterface
module top;
  aif ua();
  zif uz();
endmodule
