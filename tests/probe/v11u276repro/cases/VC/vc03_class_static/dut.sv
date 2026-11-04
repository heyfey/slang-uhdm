// § caUserCallRhsNotReduced276
class C; static function logic [31:0] f(logic [11:0] x); return x; endfunction endclass
module dut (output logic [31:0] o);
  localparam logic [11:0] K = 12'hFFF;
  assign o = C::f(K);
endmodule
