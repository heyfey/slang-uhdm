// vbuvm7 adversarial arm A — SCOPED and HIERARCHICAL bases for the collapse.
typedef struct { int used; int c; } stA_t;
package pkA;
  typedef struct { int used; int c; } stP_t;
  stP_t parr[4];
  function void fp();
    parr[1].used++;            // A1 package var, INSIDE the package
  endfunction
endpackage
class cstat;
  static stA_t sarr[4];
  static function void fs();
    sarr[2].used++;            // A2 static property from a static method
  endfunction
endclass
module subA;
  stA_t harr[4];
  initial harr[0].used++;      // A3 plain local (control)
endmodule
module topA;
  subA u_sub();
  stA_t larr[4];
  initial begin
    larr[1].used++;            // A4 plain local (control)
    pkA::parr[2].used++;       // A5 PACKAGE-SCOPED base  pkg::arr[i].f++
    cstat::sarr[3].used++;     // A6 CLASS-SCOPED static base C::arr[i].f++
    u_sub.harr[1].used++;      // A7 HIERARCHICAL base   inst.arr[i].f++
    topA.larr[2].used++;       // A8 self-hierarchical base
  end
endmodule
