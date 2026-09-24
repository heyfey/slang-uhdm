// § unsignedScalarVecTsAtKeyword137
module top(output logic o);
  function automatic bit unsigned f(input bit unsigned a);
    bit unsigned t;
    logic unsigned u;
    t = a; u = t;
    return u;
  endfunction
  assign o = f(1'b1);
endmodule
