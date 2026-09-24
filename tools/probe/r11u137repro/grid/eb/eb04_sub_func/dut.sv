// § elabCloneFullNameUnstored137
module lfsr(output logic [3:0] o);
  function automatic logic [3:0] get_1s(input int n);
    get_1s = '1;
  endfunction
  assign o = get_1s(4);
endmodule
module top(output logic [3:0] o);
  lfsr u_lfsr(.o(o));
endmodule
