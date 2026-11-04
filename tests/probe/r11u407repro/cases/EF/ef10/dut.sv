// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [7:0] {
    A = 8'h00,
    B = 8'h20
  } t_e;
  task automatic t(input t_e x, output logic y);
    y = (x == B);
  endtask
  function automatic t_e g(t_e x);
    t_e v;
    v = A;
    return x == B ? v : B;
  endfunction
endpackage
module top(input p::t_e i, output p::t_e o);
  assign o = p::g(i);
endmodule
