// § unsignedScalarVecTsAtKeyword137
module top(output bit o);
  function automatic bit g(input bit x);
    bit unsigned t;
    logic unsigned u;
    t = x; u = t;
    return u;
  endfunction
  assign o = g(1'b1);
endmodule
