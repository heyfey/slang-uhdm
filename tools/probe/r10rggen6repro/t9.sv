module m #(parameter int W = 4)(
  output logic [W-1:0] o,
  output logic         p,
  output logic [W-1:0] q,
  output logic         r
);
  assign o = '0;
  assign p = '1;
  assign q = f();
  assign r = g();
  function automatic logic [W-1:0] f();
    return '1;
  endfunction
  function automatic logic g();
    return '1;
  endfunction
endmodule
module top(output logic [3:0] o, output logic p,
           output logic [3:0] q, output logic r);
  m u(o, p, q, r);
endmodule
