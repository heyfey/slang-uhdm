// § ndaConstRhsFreshLhs271
package pk;
  typedef enum logic [1:0] { EA, EB = 2 } e_t;
endpackage
module sub (output logic [31:0] o);
  if (1) begin : g
    wire [31:0] w_e = pk::EB;
    assign o = w_e;
  end
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
