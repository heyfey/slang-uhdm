// § castPatTagKeyLocThroughParens302
// vc07: a cast-wrapped pattern as a class property initializer and a class parameter default
package p;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
  class C #(parameter cfg_t D = cfg_t'('{n: 1, h: 2}));
    cfg_t m = cfg_t'('{n: 3, h: 4});
  endclass
endpackage
module dut (output logic o);
  p::C #() c;
  assign o = 1'b0;
endmodule
