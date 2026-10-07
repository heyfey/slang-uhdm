// § caUserCallRhsNotReduced276
module kid (output logic [31:0] o);
  function automatic logic [31:0] f(logic [11:0] x); return x + 1; endfunction
  parameter logic [11:0] K = 12'hFFF;
  assign o = f(K);
endmodule
module dut (output logic [31:0] o, o2);
  kid #(.K(12'h5)) u (.o(o));
  kid u2 (.o(o2));
endmodule
