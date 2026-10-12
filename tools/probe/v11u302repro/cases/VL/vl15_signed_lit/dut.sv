// § modFnLitLeftoverValueGate302v
// vl15: signed sized literals sign-extended into wider members and a decimal literal wrapping a narrow member
package pk;
  typedef struct packed { logic [7:0] a; logic signed [7:0] b; logic [2:0] d; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 4'sb1010; c.b = 8'sd200; c.d = 9; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam logic [7:0] LA = L.a;
  assign o = 1'b0;
endmodule
