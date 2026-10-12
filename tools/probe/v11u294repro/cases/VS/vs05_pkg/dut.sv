// § paramInitMemberSelLvShape294
// a package localparam reading a select of a package struct parameter
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; logic [1:0][3:0] m; } c_t;
  localparam c_t C = '{u: 8'h35, d: 8'hA6, m: 8'h21};
endpackage
package pk2;
  localparam pk::c_t C2 = pk::C;
  localparam logic B = C2.d[3];
endpackage
module dut(output logic [7:0] o); assign o = pk2::B; endmodule
