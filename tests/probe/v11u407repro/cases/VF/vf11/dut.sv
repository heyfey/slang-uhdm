// § pkgRetEnumOperandFold407
package p;
  typedef enum logic [7:0] { A = 'h01, B = 'h20 } t_e;
  function automatic logic f(t_e x);
    begin
      return (x != A);
    end
  endfunction
  function automatic logic g(t_e x);
    logic r;
    r = x[0];
    return r && (x == B);
  endfunction
endpackage
module top(input p::t_e i, output logic o, output logic o2);
  assign o = p::f(i);
  assign o2 = p::g(i);
endmodule
