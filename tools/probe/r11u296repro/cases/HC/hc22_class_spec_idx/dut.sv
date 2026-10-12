// § hcTrailIdxNamesByPortChain296
module sub (input logic a, output logic y);
  assign y = a;
endmodule
class cw #(int W = 2);
  static function int get(); return W; endfunction
endclass
module dut(output logic y);
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  sub u (.a(q.f[cw#(3)::W]), .y(y));
endmodule
