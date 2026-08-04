module sub #(parameter bit R = 1)(output logic o);
  assign o = f(R);
  function automatic logic f(logic acc); return acc; endfunction
endmodule
module mid(output logic o);
  sub s0(o);
endmodule
module top(output logic a, output logic b, output logic c);
  mid m0(a);
  sub u0(b);
  genvar g;
  generate for (g = 0; g < 2; g++) begin : gb
    sub u1();
  end endgenerate
  assign c = 1'b0;
endmodule
