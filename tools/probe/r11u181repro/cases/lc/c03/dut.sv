// § procLvIdxCallWholeSpan181 — control: a call as a continuous-assignment lvalue select index (mem2reg_test4's shape)
module top(output logic [9:0] r);
  wire signed [9:0] im [0:3];
  function integer d2i; input integer depth; d2i = depth; endfunction
  assign im[d2i(1)] = 1;
  assign im[d2i(2)] = 2;
  assign r = im[d2i(2)];
endmodule
