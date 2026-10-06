// § ndaImpEnumConstUnlocated271
package pk;
  typedef enum logic [3:0] { EA = 1, EB = 9 } e_t;
  localparam int PQ = 6;
endpackage
module sub #(parameter bit EN = 1) (output logic [35:0] o);
  import pk::*;
  if (EN) begin : g
    wire [3:0] w_e = EB;
    wire [31:0] w_p = PQ;
    assign o = {w_p, w_e};
  end else begin : h
    assign o = '0;
  end
endmodule
module dut (output logic [35:0] o);
  sub u_s (.o(o));
endmodule
