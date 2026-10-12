// § paramInitMemberSelLvShape294
// a module-body struct localparam (not a header parameter)
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; logic [1:0][3:0] m; } c_t;
  localparam c_t C = '{u: 8'h35, d: 8'hA6, m: 8'h21};
endpackage
module dut(output logic [7:0] o);
  localparam pk::c_t L = '{u: 8'h12, d: 8'h34, m: 8'h56};
  localparam logic B = L.d[3];
  assign o = B;
endmodule
