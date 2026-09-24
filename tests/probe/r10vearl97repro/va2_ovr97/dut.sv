// v97 va2 -- OVERRIDE DEPENDENCE, INSTANCE ARRAYS, THREE INSTANCES OF ONE SPAN.
// The cast-site copy is minted per elaborated instance; each instance must get
// the SAME VpiSigned as its declaration, and an instance ARRAY must not differ
// from three separate instances.
module topva2;
  logic [31:0] a, b, c;
  logic [31:0] arr [3];
  subva2 #(.P(8))  u_1(.o(a));
  subva2 #(.P(16)) u_2(.o(b));
  subva2 #(.P(8))  u_3(.o(c));
  subva2 #(.P(5))  u_arr [3] (.o(arr));
endmodule
module subva2 #(parameter int P = 4) (output logic [31:0] o);
  logic [3:0] m;
  localparam int WOVR = $clog2(P + 1);          // override-dependent
  localparam int unsigned WOVU = $clog2(P + 2); // override-dependent, unsigned
  assign o = 32'(WOVR'(m)) + 32'(WOVU'(m));
endmodule
