// § paramInitMemberSelLvShape294
// an interface localparam
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; logic [1:0][3:0] m; } c_t;
  localparam c_t C = '{u: 8'h35, d: 8'hA6, m: 8'h21};
endpackage
interface ifc #(parameter pk::c_t CFG = pk::C) ();
  localparam logic B = CFG.d[0];
  logic s;
  assign s = B;
endinterface
module dut(output logic o); ifc i0 (); assign o = i0.s; endmodule
