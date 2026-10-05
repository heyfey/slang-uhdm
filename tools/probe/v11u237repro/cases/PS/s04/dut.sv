// § bitsArgNotReduced237v
// the select only inside $bits()
package q;
  typedef struct packed { logic [3:0] e; logic [3:0] m; } enc_t;
  localparam enc_t [0:2] ENC = '{'{4'd4, 4'd3}, '{4'd3, 4'd2}, '{4'd2, 4'd1}};
  function automatic int unsigned fw(int unsigned i);
    return $bits(ENC[i]) + i;
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(1)) u (.o(o));
endmodule
