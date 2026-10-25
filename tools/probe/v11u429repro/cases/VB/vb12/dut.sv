// § genBodyBitsOuterNameKeeps429
module top (output logic [7:0] y);
  logic [4:0] x;
  if (1) begin: g
    function automatic int f();
      return $bits(x);
    endfunction
    always_comb y = f();
  end
endmodule
