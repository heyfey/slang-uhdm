// § trailIdxCallArgNamesByPath187 (an interface-port path with a call index)
interface bif;
  logic [7:0] q;
endinterface
module m(bif b, input int k, output logic o);
  function automatic int f(int x); return x; endfunction
  assign o = b.q[f(k)];
endmodule
module top(input int k, output logic o);
  bif b();
  m u(.b(b), .k(k), .o(o));
endmodule
