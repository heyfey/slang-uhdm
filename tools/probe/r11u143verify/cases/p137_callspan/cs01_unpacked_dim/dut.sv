// § constCallNameSpan137
// case cs01: a user call in an unpacked dimension bound
module top(output logic o);
  function automatic int sz(input int x); return x * 2; endfunction
  logic m [sz(2)];
  logic n [0:sz(1)-1];
  assign m[0] = 1'b1;
  assign o = m[0];
endmodule
