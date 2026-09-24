// § elabPatQualRefQualSpan133
// case pq01: package pattern parameter written positionally, qualified default
package cp;
  typedef struct packed { int unsigned W; bit E; } c_t;
  localparam c_t Base = '{16, 1'b1};
endpackage
module dut #(parameter cp::c_t C = cp::Base) (output logic [31:0] o);
  assign o = C.W;
endmodule
