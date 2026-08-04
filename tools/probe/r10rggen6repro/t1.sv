module sub #(
  parameter bit READABLE = 1,
  parameter bit WRITABLE = 1
)(output logic o);
  assign o = f(1'b0, READABLE, WRITABLE);
  function automatic logic f(logic w, logic accessible, logic acc2);
    return accessible | acc2 | w;
  endfunction
endmodule

module top(output logic a, output logic b, output logic c);
  sub u0(a);
  sub u1(b);
  sub u2(c);
endmodule
