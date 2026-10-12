// § paramInitMemberSelLvShape294
// a wildcard-imported package struct parameter read with a select
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; logic [1:0][3:0] m; } c_t;
  localparam c_t C = '{u: 8'h35, d: 8'hA6, m: 8'h21};
endpackage
module dut(output logic o, p);
  import pk::*;
  localparam logic B = C.d[3];
  localparam logic E = pk::C.d[0];
  assign o = B;
  assign p = E;
endmodule
