// r10v96 arm 2 — the SAME moving keywords across every CARRIER.
package v96p2;
  parameter int PBASE = integer'(8);          // param init
  parameter real PR   = real'(3);
  function automatic real fret(logic [15:0] q);
    return real'(q);                          // return
  endfunction
  function automatic longint fret2(logic [15:0] q);
    return longint'(q);
  endfunction
  function automatic int sink(int a); return a; endfunction

  function automatic void f2(logic [15:0] q, real r);
    real         x;
    int          y;
    logic [31:0] w;
    x = real'(q);                              // assignment
    y = int'(q) + integer'(q);                 // operation operands (control + mover)
    y = sink(shortint'(q));                    // call arg
    if (real'(q) > 0.0) y = 1;                 // condition
    case (integer'(q))                         // case expression
      integer'(1): y = 2;                      // case item
      default:     y = 3;
    endcase
    w = {byte'(q), shortint'(q)};              // concat (control + mover)
    w = {2{shortint'(q)}};                     // replication
    y = (q[0]) ? int'(q) : integer'(q);        // ternary
    x = time'(q) + realtime'(q);               // both time roads
    x = shortreal'(r);
    $display("%0d %0d %0f %0d %0d", y, w, x, fret(q), fret2(q));
  endfunction
endpackage

module v96m2;
  localparam int LB = integer'(4);
  logic [LB-1:0] bus;                          // range bound via a moved param
  wire [integer'(3):0] wb;                     // range bound, direct
  initial v96p2::f2(16'hbeef, 2.5);
  assign wb = bus;
endmodule
