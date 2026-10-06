// § ndaConstRhsFreshLhs271
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam s_t PS = '{a: 4'h3, b: 4'h9};
endpackage
module sub (output logic [7:0] o);
  wire [3:0] w_a = pk::PS.a;
  wire [7:0] w_s = pk::PS;
  assign o = {w_a, w_s[3:0]};
endmodule
module dut (output logic [7:0] o);
  sub u_s (.o(o));
endmodule
