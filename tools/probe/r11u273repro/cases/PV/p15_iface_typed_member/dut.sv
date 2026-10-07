// § paramValRhsSharesParamConst273
package pk;
  typedef struct packed { logic [7:0] n; logic [7:0] m; } s_t;
endpackage
interface ifc #(parameter pk::s_t C = '{n: 8'd3, m: 8'd5}) ();
  logic [31:0] y;
  assign y = C.n;
endinterface
module dut (output logic [31:0] o);
  ifc u_d ();
  assign o = u_d.y;
endmodule
