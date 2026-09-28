// § classValueParamIntSigned202
class c #(parameter int W = -4, localparam int M = W * 2);
  function int get(); return M; endfunction
endclass
module v04;
  c #(-3) h;
  c k;
endmodule
