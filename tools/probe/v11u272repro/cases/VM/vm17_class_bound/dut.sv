// § leftoverTsCopyPerElabUse272
// (no continuous-assignment read of the parameter) a class specialization in a bound and a this path
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
class cl #(int W = 1);
  int v;
  function int get(); return this.v + W; endfunction
  static function int width(); return W; endfunction
endclass
module kid #(parameter pk::c_t P = pk::C) (output logic [31:0] o);
  logic [cl#(P.u.a)::width()-1:0] w;
  initial begin
    cl#(P.u.b) h = new;
    h.v = P.d;
    w = h.get();
  end
  assign o = w;
endmodule
module dut(output logic [31:0] o);
  kid k0 (.o(o));
endmodule
