// r11v75 xd — LAW C across TWO INSTANCES of the same module.  `genScopeParamObj75`
// is keyed on the slang ParameterSymbol; if slang shares one InstanceBodySymbol
// between two identically-parameterised instances, the second `emitGenScopes`
// overwrites the map entry and the drain reads the OTHER instance's typespec.
// Also asks the fold inside an INTERFACE's generate scope.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
endpackage

interface ifc (output logic [31:0] q);
  if (1) begin : gi
    localparam p::cfg_t I_LOC = p::build(700);
    logic [31:0] i_n;  assign i_n = I_LOC.n;
  end
  assign q = gi.i_n;
endinterface

module child (output logic [31:0] o);
  if (1) begin : gc
    localparam p::cfg_t C_LOC = p::build(384);
    logic [31:0] c_n;  assign c_n = C_LOC.n;
    logic [7:0]  c_t;  assign c_t = C_LOC.t;
  end
  assign o = gc.c_n ^ {24'd0, gc.c_t};
endmodule

module dut (output logic [31:0] o);
  logic [31:0] o1, o2, oi;
  child u1 (.o(o1));
  child u2 (.o(o2));
  ifc   ui (.q(oi));
  assign o = o1 ^ o2 ^ oi;
endmodule
