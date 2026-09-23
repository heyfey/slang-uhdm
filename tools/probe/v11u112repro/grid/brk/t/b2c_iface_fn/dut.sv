interface bi;
  typedef logic signed [15:0] s_t;
  logic [15:0] d;
  function automatic s_t sx(logic [7:0] v); return s_t'($signed(v)); endfunction
endinterface
module m(input logic [7:0] x, output logic [15:0] y);
  bi u();
  assign y = u.sx(x);
endmodule
