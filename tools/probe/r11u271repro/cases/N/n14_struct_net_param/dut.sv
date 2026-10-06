// § ndaConstRhsFreshLhs271
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam s_t SP = '{a: 4'h1, b: 4'h2};
endpackage
module sub (output logic [7:0] o);
  wire pk::s_t w_s = pk::SP;
  assign o = w_s;
endmodule
module dut (output logic [7:0] o);
  sub u_s (.o(o));
endmodule
