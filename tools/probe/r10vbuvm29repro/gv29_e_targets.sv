// r10vbuvm29 arm E (VERIFIER) — cast TARGET kinds arm B did not reach:
// a packed UNION, a two-dimensional packed vector, a SIGNED vector typedef,
// an enum typedef declared in ANOTHER package and referenced SCOPED, a
// `longint`, and a `time`.
package ve29base;
  typedef enum bit [7:0] { A0 = 8'h10, A1 = 8'h20 } far_e;
endpackage
package ve29;
  import ve29base::*;
  typedef union packed { bit [7:0] u8; struct packed { bit [3:0] hi, lo; } f; } up;
  typedef logic signed [15:0] sv_t;
  typedef bit [1:0][7:0] two_d;
  class C;
    up q1; sv_t q2; two_d q3; ve29base::far_e q4; longint q6; time q7;
    bit __a[];
    function void f();
      q1 = up'({ << bit { __a }});
      q2 = sv_t'({ << bit { __a }});
      q3 = two_d'({ << bit { __a }});
      q4 = ve29base::far_e'({ << bit { __a }});
      q6 = longint'({ << bit { __a }});
      q7 = time'({ << bit { __a }});
    endfunction
  endclass
endpackage
