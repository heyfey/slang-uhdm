// § modFnLitLeftoverAtLiteral302
// vl04: the builder is a static function of a class declared in the module
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module dut(output logic o);
  class B;
    static function pk::c_t mk();
      pk::c_t c; c.a = 7; c.b = 70; return c;
    endfunction
  endclass
  localparam pk::c_t L = B::mk();
  localparam int unsigned LA = L.a;
  assign o = 1'b0;
endmodule
