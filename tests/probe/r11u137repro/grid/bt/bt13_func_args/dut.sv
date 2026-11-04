// § unsignedScalarVecTsAtKeyword137
module top(output bit o);
  function automatic bit unsigned f(input bit unsigned x, input logic unsigned y);
    return x ^ y;
  endfunction
  assign o = f(1'b1, 1'b0);
endmodule
