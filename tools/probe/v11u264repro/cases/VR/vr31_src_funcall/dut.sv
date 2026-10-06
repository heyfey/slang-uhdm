// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  function automatic int f(int x); return x * 2; endfunction
  localparam int A = f(3);
  localparam int B = A;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
