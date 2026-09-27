// § trailIdxCallArgNamesByPath187 (an interface path)
interface bif;
  logic [3:0] q;
endinterface
module m(bif b, input int k, output logic o);
  function automatic int f(int x); return x; endfunction
  assign o = b.q[f(k)];
endmodule
module top(input int k, output logic o);
  bif bb();
  m u(.b(bb), .k(k), .o(o));
endmodule
