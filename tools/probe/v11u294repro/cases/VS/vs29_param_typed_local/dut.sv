// § paramInitMemberSelLvShape294
// a struct parameter typed by a module-local typedef
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; logic [1:0][3:0] m; } c_t;
  localparam c_t C = '{u: 8'h35, d: 8'hA6, m: 8'h21};
endpackage
module dut(output logic o);
  typedef struct packed { logic [3:0] x; logic [7:0] d; } l_t;
  localparam l_t L = '{x: 4'h3, d: 8'hF0};
  localparam logic B = L.d[2];
  assign o = B;
endmodule
