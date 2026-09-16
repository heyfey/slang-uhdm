// r11u49 arm a4 — an unpacked struct with NON-INTEGRAL / nested members:
// a nested unpacked struct, a nested PACKED struct, and a real string member.
package p;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } inner_p_t;
  typedef struct        { int unsigned m; int unsigned n; } inner_u_t;
  typedef struct { inner_p_t ip; int unsigned k; } mixp_t;
  typedef struct { inner_u_t iu; int unsigned k; } mixu_t;
  localparam mixp_t MP = '{ip: '{x:4'h1, y:4'h2}, k: 5};
  localparam mixu_t MU = '{iu: '{m:1, n:2}, k: 6};
endpackage
module a4 (output logic [31:0] o);
  assign o = p::MP.k + p::MU.k;
endmodule
