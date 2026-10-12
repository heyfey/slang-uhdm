// § retFoldTsKeyedByParam296
package p;
  typedef enum logic [1:0] {X0, X1, X2} e_t;
  parameter e_t A = X1;
  parameter e_t B = X2;
  function e_t f(input bit s);
    if (s) return A;
    return B;
  endfunction
endpackage
module dut(output logic [1:0] o);
  initial o = p::f(1'b0);
endmodule
