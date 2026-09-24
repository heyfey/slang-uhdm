// § constCallNameSpan137
module top(output logic o);
  function automatic int f(input int x); return x + 1; endfunction
  logic [f(3)-1:0] v;
  logic [$clog2(8)-1:0] w;
  assign o = v[0] ^ w[0];
endmodule
